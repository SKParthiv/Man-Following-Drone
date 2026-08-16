#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Man-Following Drone
# Reproducible development environment
#
# Behaviour:
#   1. Detect current environment
#   2. Verify requirements
#   3. Install/fix only what is necessary
#   4. Verify again
#
# The target environment is defined by:
#   config/versions.json
# ============================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="${PROJECT_ROOT}/config/versions.json"
VENV="${PROJECT_ROOT}/.venv"
ROS_WS="${PROJECT_ROOT}/ros2_ws"

# ------------------------------------------------------------
# Output helpers
# ------------------------------------------------------------

print_header() {
    echo
    echo "=========================================="
    echo " $1"
    echo "=========================================="
    echo
}

print_section() {
    echo
    echo "------------------------------------------"
    echo " $1"
    echo "------------------------------------------"
}

pass() {
    echo "[PASS] $1"
}

warn() {
    echo "[WARN] $1"
}

fail() {
    echo "[FAIL] $1"
}

info() {
    echo "[INFO] $1"
}

# ------------------------------------------------------------
# Basic prerequisites
# ------------------------------------------------------------

if [[ "${EUID}" -eq 0 ]]; then
    echo "ERROR: Do not run setup.sh as root."
    echo "Run it as your normal user. sudo will be requested when needed."
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: Python 3 is required to read ${VERSION_FILE}."
    exit 1
fi

if [[ ! -f "${VERSION_FILE}" ]]; then
    echo "ERROR: ${VERSION_FILE} not found."
    exit 1
fi

# ------------------------------------------------------------
# Read configuration
# ------------------------------------------------------------

read_config() {
    local config_output

    config_output="$(
        python3 - "${VERSION_FILE}" <<'PY'
import json
import sys

path = sys.argv[1]

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

required = [
    ("ubuntu", "version"),
    ("ubuntu", "codename"),
    ("ubuntu", "architecture"),
    ("ros", "distro"),
    ("gazebo", "distro"),
    ("python", "version"),
]

for section, key in required:
    if section not in data:
        raise SystemExit(f"Missing configuration section: {section}")

    if key not in data[section]:
        raise SystemExit(
            f"Missing configuration value: {section}.{key}"
        )

print(data["ubuntu"]["version"])
print(data["ubuntu"]["codename"])
print(data["ubuntu"]["architecture"])
print(data["ros"]["distro"])
print(data["gazebo"]["distro"])
print(data["python"]["version"])
PY
    )"

    mapfile -t CONFIG_VALUES <<< "${config_output}"

    if [[ "${#CONFIG_VALUES[@]}" -ne 6 ]]; then
        echo "ERROR: Invalid versions.json."
        exit 1
    fi

    UBUNTU_VERSION="${CONFIG_VALUES[0]}"
    UBUNTU_CODENAME="${CONFIG_VALUES[1]}"
    ARCHITECTURE="${CONFIG_VALUES[2]}"
    ROS_DISTRO="${CONFIG_VALUES[3]}"
    GAZEBO_DISTRO="${CONFIG_VALUES[4]}"
    PYTHON_VERSION="${CONFIG_VALUES[5]}"
}

read_config

# ------------------------------------------------------------
# Display target environment
# ------------------------------------------------------------

print_header "Man-Following Drone Setup"

echo "Target environment:"
echo "  Ubuntu   : ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"
echo "  Arch     : ${ARCHITECTURE}"
echo "  ROS 2    : ${ROS_DISTRO}"
echo "  Gazebo   : ${GAZEBO_DISTRO}"
echo "  Python   : ${PYTHON_VERSION}"
echo

# ------------------------------------------------------------
# Detect operating system
# ------------------------------------------------------------

print_section "System Detection"

if [[ ! -f /etc/os-release ]]; then
    fail "/etc/os-release not found."
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
    fail "Ubuntu is required."
    echo "      Detected: ${ID:-unknown}"
    exit 1
fi

if [[ "${VERSION_ID:-}" != "${UBUNTU_VERSION}" ]]; then
    fail "Wrong Ubuntu version."
    echo "      Required: ${UBUNTU_VERSION}"
    echo "      Detected: ${VERSION_ID:-unknown}"
    exit 1
fi

if [[ "${VERSION_CODENAME:-}" != "${UBUNTU_CODENAME}" ]]; then
    fail "Wrong Ubuntu codename."
    echo "      Required: ${UBUNTU_CODENAME}"
    echo "      Detected: ${VERSION_CODENAME:-unknown}"
    exit 1
fi

CURRENT_ARCH="$(dpkg --print-architecture)"

if [[ "${CURRENT_ARCH}" != "${ARCHITECTURE}" ]]; then
    fail "Wrong architecture."
    echo "      Required: ${ARCHITECTURE}"
    echo "      Detected: ${CURRENT_ARCH}"
    exit 1
fi

pass "Ubuntu ${VERSION_ID} (${VERSION_CODENAME})"
pass "Architecture: ${CURRENT_ARCH}"

# ------------------------------------------------------------
# Detect WSL
# ------------------------------------------------------------

if grep -qi microsoft /proc/version 2>/dev/null; then
    pass "WSL detected"

    if [[ -n "${WSL_INTEROP:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
        pass "WSL GUI environment detected"
    else
        warn "WSL detected but WSLg environment variables are not present."
        warn "Gazebo GUI may not be available."
    fi
else
    warn "WSL was not detected."
    warn "Continuing because the script itself does not require WSL."
fi

# ------------------------------------------------------------
# APT health
# ------------------------------------------------------------

print_section "APT Health"

if ! sudo -n true 2>/dev/null; then
    info "sudo access is required."
    sudo -v
fi

if ! sudo dpkg --audit >/dev/null 2>&1; then
    warn "dpkg reports package problems."
    info "Attempting to configure unfinished packages..."

    sudo dpkg --configure -a

    if ! sudo dpkg --audit >/dev/null 2>&1; then
        fail "dpkg is still in an inconsistent state."
        exit 1
    fi
fi

if ! sudo apt-get check >/dev/null 2>&1; then
    warn "APT dependency problems detected."
    info "Attempting to repair APT dependencies..."

    sudo apt-get -f install -y

    if ! sudo apt-get check >/dev/null 2>&1; then
        fail "APT is still unhealthy."
        exit 1
    fi
fi

pass "APT package state is healthy"

info "Updating package indexes..."

sudo apt-get update

pass "APT package indexes updated"

# ------------------------------------------------------------
# Ubuntu Universe
# ------------------------------------------------------------

print_section "Ubuntu Repositories"

if ! apt-cache policy 2>/dev/null | grep -q "universe"; then
    info "Universe repository may not be enabled."
    info "Enabling Ubuntu Universe..."

    sudo add-apt-repository -y universe
    sudo apt-get update
fi

pass "Ubuntu Universe repository available"

# ------------------------------------------------------------
# Package installation helper
# ------------------------------------------------------------

package_installed() {
    dpkg-query \
        -W \
        -f='${Status}' \
        "$1" 2>/dev/null |
        grep -q "install ok installed"
}

install_missing_packages() {
    local missing=()
    local package

    for package in "$@"; do
        if package_installed "${package}"; then
            pass "${package}"
        else
            missing+=("${package}")
            info "${package}: missing"
        fi
    done

    if [[ "${#missing[@]}" -gt 0 ]]; then
        echo
        info "Installing missing packages:"
        printf '       %s\n' "${missing[@]}"

        sudo apt-get install -y "${missing[@]}"
    fi
}

# ------------------------------------------------------------
# Base development packages
# ------------------------------------------------------------

print_section "Base Development Tools"

BASE_PACKAGES=(
    build-essential
    cmake
    ninja-build
    pkg-config
    curl
    gnupg
    lsb-release
    software-properties-common
    git
    python3-dev
    python3-venv
    python3-pip
)

install_missing_packages "${BASE_PACKAGES[@]}"

pass "Base development tools"

# ------------------------------------------------------------
# Python version
# ------------------------------------------------------------

print_section "Python"

CURRENT_PYTHON_VERSION="$(
    python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'
)"

if [[ "${CURRENT_PYTHON_VERSION}" != "${PYTHON_VERSION}" ]]; then
    fail "Python version mismatch."
    echo "      Required: ${PYTHON_VERSION}"
    echo "      Detected: ${CURRENT_PYTHON_VERSION}"
    exit 1
fi

pass "Python ${CURRENT_PYTHON_VERSION}"

if python3 -m pip --version >/dev/null 2>&1; then
    pass "pip available"
else
    fail "pip is unavailable."
    exit 1
fi

if python3 -c 'import venv' >/dev/null 2>&1; then
    pass "Python venv support available"
else
    fail "Python venv support unavailable."
    exit 1
fi

# ------------------------------------------------------------
# ROS 2 repository
# ------------------------------------------------------------

print_section "ROS 2 Repository"

ROS_APT_SOURCE_PACKAGE="ros2-apt-source"

if package_installed "${ROS_APT_SOURCE_PACKAGE}"; then
    pass "ROS 2 APT repository package installed"
else
    info "ROS 2 APT repository package missing."
    info "Configuring ROS 2 repository..."

    ROS_APT_SOURCE_VERSION="$(
        curl -fsSL \
            https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest |
        python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(data["tag_name"])
'
    )"

    if [[ -z "${ROS_APT_SOURCE_VERSION}" ]]; then
        fail "Could not determine ros-apt-source release."
        exit 1
    fi

    ROS_APT_SOURCE_DEB="/tmp/ros2-apt-source.deb"

    curl -fL \
        -o "${ROS_APT_SOURCE_DEB}" \
        "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${UBUNTU_CODENAME}_all.deb"

    sudo dpkg -i "${ROS_APT_SOURCE_DEB}"

    rm -f "${ROS_APT_SOURCE_DEB}"

    sudo apt-get update

    pass "ROS 2 APT repository configured"
fi

# ------------------------------------------------------------
# ROS development tools
# ------------------------------------------------------------

print_section "ROS 2 Development Tools"

if package_installed "ros-dev-tools"; then
    pass "ros-dev-tools"
else
    info "Installing ROS development tools..."
    sudo apt-get install -y ros-dev-tools
    pass "ros-dev-tools"
fi

# ------------------------------------------------------------
# ROS 2
# ------------------------------------------------------------

print_section "ROS 2 ${ROS_DISTRO}"

ROS_DESKTOP_PACKAGE="ros-${ROS_DISTRO}-desktop"

if package_installed "${ROS_DESKTOP_PACKAGE}"; then
    pass "${ROS_DESKTOP_PACKAGE}"
else
    info "ROS 2 ${ROS_DISTRO} is missing."
    info "Installing ${ROS_DESKTOP_PACKAGE}..."

    sudo apt-get install -y "${ROS_DESKTOP_PACKAGE}"

    pass "ROS 2 ${ROS_DISTRO}"
fi

ROS_SETUP="/opt/ros/${ROS_DISTRO}/setup.bash"

if [[ ! -f "${ROS_SETUP}" ]]; then
    fail "ROS setup file not found: ${ROS_SETUP}"
    exit 1
fi

pass "ROS setup file"

# ------------------------------------------------------------
# ROS environment loading
#
# ROS setup scripts can reference variables that are unset.
# This conflicts with `set -u`, producing:
#
#   AMENT_TRACE_SETUP_FILES: unbound variable
#
# Temporarily disable nounset while sourcing ROS.
# ------------------------------------------------------------

source_ros() {
    set +u
    # shellcheck disable=SC1090
    source "${ROS_SETUP}"
    set -u
}

source_ros

if command -v ros2 >/dev/null 2>&1; then
    pass "ros2 command available"
else
    fail "ros2 command unavailable after sourcing ${ROS_SETUP}"
    exit 1
fi

# ------------------------------------------------------------
# ROS tooling verification
# ------------------------------------------------------------

print_section "ROS 2 Tooling"

ROS_COMMANDS=(
    ros2
    colcon
    rosdep
)

for command_name in "${ROS_COMMANDS[@]}"; do
    if command -v "${command_name}" >/dev/null 2>&1; then
        pass "${command_name}"
    else
        fail "${command_name} unavailable"
        exit 1
    fi
done

# ------------------------------------------------------------
# Gazebo + ROS integration
# ------------------------------------------------------------

print_section "Gazebo ${GAZEBO_DISTRO}"

ROS_GZ_PACKAGE="ros-${ROS_DISTRO}-ros-gz"

if package_installed "${ROS_GZ_PACKAGE}"; then
    pass "${ROS_GZ_PACKAGE}"
else
    info "ROS-Gazebo integration is missing."
    info "Installing ${ROS_GZ_PACKAGE}..."

    sudo apt-get install -y "${ROS_GZ_PACKAGE}"

    pass "${ROS_GZ_PACKAGE}"
fi

source_ros

if ! command -v gz >/dev/null 2>&1; then
    fail "Gazebo 'gz' command is unavailable."
    exit 1
fi

pass "Gazebo command available"

GAZEBO_VERSION_OUTPUT="$(gz sim --version 2>&1 || true)"

if [[ -z "${GAZEBO_VERSION_OUTPUT}" ]]; then
    fail "Could not determine Gazebo version."
    exit 1
fi

echo
echo "Gazebo:"
echo "${GAZEBO_VERSION_OUTPUT}"

if grep -qi "${GAZEBO_DISTRO}" <<< "${GAZEBO_VERSION_OUTPUT}"; then
    pass "Gazebo ${GAZEBO_DISTRO}"
else
    warn "Gazebo executable is present, but the reported version did not explicitly contain '${GAZEBO_DISTRO}'."
    warn "This is a warning rather than an automatic failure."
fi

# ------------------------------------------------------------
# rosdep
# ------------------------------------------------------------

print_section "rosdep"

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
    info "rosdep has not been initialized."
    info "Initializing rosdep..."

    sudo rosdep init
else
    pass "rosdep already initialized"
fi

info "Updating rosdep database..."

rosdep update

pass "rosdep"

# ------------------------------------------------------------
# Python virtual environment
# ------------------------------------------------------------

print_section "Python Virtual Environment"

if [[ ! -d "${VENV}" ]]; then
    info "Creating Python virtual environment..."
    python3 -m venv "${VENV}"
else
    pass "Virtual environment already exists"
fi

# shellcheck disable=SC1091
source "${VENV}/bin/activate"

info "Updating pip..."

python -m pip install --upgrade pip

if [[ -f "${PROJECT_ROOT}/requirements.txt" ]]; then
    info "Installing Python project requirements..."
    python -m pip install -r "${PROJECT_ROOT}/requirements.txt"
    pass "Python requirements"
else
    info "No requirements.txt found."
    pass "No Python requirements to install"
fi

deactivate

# ------------------------------------------------------------
# ROS workspace
# ------------------------------------------------------------

print_section "ROS Workspace"

mkdir -p "${ROS_WS}/src"

if [[ -d "${ROS_WS}/src" ]]; then
    pass "ROS workspace"
else
    fail "Could not create ROS workspace."
    exit 1
fi

# ------------------------------------------------------------
# .bashrc ROS environment
# ------------------------------------------------------------

print_section "Shell Environment"

ROS_SETUP_LINE="source ${ROS_SETUP}"

if grep -Fxq "${ROS_SETUP_LINE}" "${HOME}/.bashrc" 2>/dev/null; then
    pass "ROS environment already configured in .bashrc"
else
    info "Adding ROS environment to .bashrc..."
    echo
    echo "# Man-Following Drone ROS 2 environment" >> "${HOME}/.bashrc"
    echo "${ROS_SETUP_LINE}" >> "${HOME}/.bashrc"

    pass "ROS environment configured in .bashrc"
fi

# ------------------------------------------------------------
# Final verification
# ------------------------------------------------------------

print_header "Final Verification"

FINAL_FAILURES=0

check_command() {
    local command_name="$1"

    if command -v "${command_name}" >/dev/null 2>&1; then
        pass "${command_name}"
    else
        fail "${command_name}"
        FINAL_FAILURES=$((FINAL_FAILURES + 1))
    fi
}

source_ros

# ROS
check_command ros2
check_command colcon
check_command rosdep

# Gazebo
check_command gz

# Development tools
check_command git
check_command gcc
check_command g++
check_command cmake
check_command ninja

# Python
if [[ "${CURRENT_PYTHON_VERSION}" == "${PYTHON_VERSION}" ]]; then
    pass "Python ${PYTHON_VERSION}"
else
    fail "Python version"
    FINAL_FAILURES=$((FINAL_FAILURES + 1))
fi

# ROS installation
if [[ -f "${ROS_SETUP}" ]]; then
    pass "ROS ${ROS_DISTRO} installation"
else
    fail "ROS ${ROS_DISTRO} installation"
    FINAL_FAILURES=$((FINAL_FAILURES + 1))
fi

# Gazebo integration package
if package_installed "${ROS_GZ_PACKAGE}"; then
    pass "ROS-Gazebo integration"
else
    fail "ROS-Gazebo integration"
    FINAL_FAILURES=$((FINAL_FAILURES + 1))
fi

# rosdep
if [[ -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
    pass "rosdep configuration"
else
    fail "rosdep configuration"
    FINAL_FAILURES=$((FINAL_FAILURES + 1))
fi

# Workspace
if [[ -d "${ROS_WS}/src" ]]; then
    pass "ROS workspace"
else
    fail "ROS workspace"
    FINAL_FAILURES=$((FINAL_FAILURES + 1))
fi

# ------------------------------------------------------------
# Version information
# ------------------------------------------------------------

echo
echo "Installed versions:"
echo

echo "Python:"
python3 --version

echo
echo "ROS 2:"
ros2 --version 2>&1 || true

echo
echo "Gazebo:"
gz sim --version 2>&1 || true

echo
echo "GCC:"
gcc --version | head -n 1

echo
echo "CMake:"
cmake --version | head -n 1

echo
echo "Colcon:"
colcon version-check 2>/dev/null || true

# ------------------------------------------------------------
# Final result
# ------------------------------------------------------------

print_header "Result"

if [[ "${FINAL_FAILURES}" -eq 0 ]]; then
    echo "ENVIRONMENT READY"
    echo
    echo "The Man-Following Drone development environment"
    echo "matches the required configuration."
    echo
    echo "ROS workspace:"
    echo "  ${ROS_WS}"
    echo
    echo "To activate the ROS environment in the current shell:"
    echo
    echo "  source /opt/ros/${ROS_DISTRO}/setup.bash"
    echo
    echo "To enter the project Python environment:"
    echo
    echo "  source ${VENV}/bin/activate"
    echo
    exit 0
else
    echo "ENVIRONMENT NOT READY"
    echo
    echo "Failures detected: ${FINAL_FAILURES}"
    echo
    echo "Review the [FAIL] entries above."
    echo
    exit 1
fi
