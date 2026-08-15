#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Man-Following Drone
# Reproducible development environment
# ============================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="${PROJECT_ROOT}/config/versions.json"

# ------------------------------------------------------------
# Check prerequisites
# ------------------------------------------------------------

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: Python 3 is required to read versions.json."
    exit 1
fi

if [[ ! -f "${VERSION_FILE}" ]]; then
    echo "ERROR: ${VERSION_FILE} not found."
    exit 1
fi

# ------------------------------------------------------------
# Read versions.json
# ------------------------------------------------------------

UBUNTU_VERSION="$(
    python3 -c \
    "import json; print(json.load(open('${VERSION_FILE}'))['ubuntu']['version'])"
)"

UBUNTU_CODENAME="$(
    python3 -c \
    "import json; print(json.load(open('${VERSION_FILE}'))['ubuntu']['codename'])"
)"

ARCHITECTURE="$(
    python3 -c \
    "import json; print(json.load(open('${VERSION_FILE}'))['ubuntu']['architecture'])"
)"

ROS_DISTRO="$(
    python3 -c \
    "import json; print(json.load(open('${VERSION_FILE}'))['ros']['distro'])"
)"

GAZEBO_DISTRO="$(
    python3 -c \
    "import json; print(json.load(open('${VERSION_FILE}'))['gazebo']['distro'])"
)"

PYTHON_VERSION="$(
    python3 -c \
    "import json; print(json.load(open('${VERSION_FILE}'))['python']['version'])"
)"

echo
echo "=========================================="
echo " Man-Following Drone Setup"
echo "=========================================="
echo
echo "Target environment:"
echo "  Ubuntu   : ${UBUNTU_VERSION} (${UBUNTU_CODENAME})"
echo "  Arch     : ${ARCHITECTURE}"
echo "  ROS 2    : ${ROS_DISTRO}"
echo "  Gazebo   : ${GAZEBO_DISTRO}"
echo "  Python   : ${PYTHON_VERSION}"
echo

# ------------------------------------------------------------
# Validate operating system
# ------------------------------------------------------------

source /etc/os-release

if [[ "${ID}" != "ubuntu" ]]; then
    echo "ERROR: Ubuntu is required."
    echo "Detected: ${ID}"
    exit 1
fi

if [[ "${VERSION_ID}" != "${UBUNTU_VERSION}" ]]; then
    echo "ERROR: Wrong Ubuntu version."
    echo "Required: ${UBUNTU_VERSION}"
    echo "Detected: ${VERSION_ID}"
    exit 1
fi

if [[ "${VERSION_CODENAME}" != "${UBUNTU_CODENAME}" ]]; then
    echo "ERROR: Wrong Ubuntu codename."
    echo "Required: ${UBUNTU_CODENAME}"
    echo "Detected: ${VERSION_CODENAME}"
    exit 1
fi

if [[ "$(dpkg --print-architecture)" != "${ARCHITECTURE}" ]]; then
    echo "ERROR: Wrong architecture."
    echo "Required: ${ARCHITECTURE}"
    echo "Detected: $(dpkg --print-architecture)"
    exit 1
fi

echo "System compatibility: OK"
echo

# ------------------------------------------------------------
# Base system packages
# ------------------------------------------------------------

echo "Installing base development packages..."

sudo apt update

sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    python3-dev \
    python3-venv \
    python3-pip

echo
echo "Base development packages: OK"
echo

# ------------------------------------------------------------
# Ubuntu Universe
# ------------------------------------------------------------

echo "Enabling Ubuntu Universe..."

sudo add-apt-repository -y universe
sudo apt update

echo "Universe: OK"
echo

# ------------------------------------------------------------
# ROS 2 repository
# ------------------------------------------------------------

echo "Configuring ROS 2 repository..."

sudo apt install -y curl

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
    echo "ERROR: Could not determine ros-apt-source release."
    exit 1
fi

ROS_APT_SOURCE_DEB="/tmp/ros2-apt-source.deb"

curl -fL \
    -o "${ROS_APT_SOURCE_DEB}" \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${UBUNTU_CODENAME}_all.deb"

sudo dpkg -i "${ROS_APT_SOURCE_DEB}"

rm -f "${ROS_APT_SOURCE_DEB}"

sudo apt update

echo "ROS 2 repository: OK"
echo

# ------------------------------------------------------------
# ROS 2 development tools
# ------------------------------------------------------------

echo "Installing ROS 2 development tools..."

sudo apt install -y ros-dev-tools

echo "ROS 2 development tools: OK"
echo

# ------------------------------------------------------------
# ROS 2
# ------------------------------------------------------------

echo "Installing ROS 2 ${ROS_DISTRO}..."

sudo apt install -y "ros-${ROS_DISTRO}-desktop"

echo "ROS 2 ${ROS_DISTRO}: OK"
echo

# ------------------------------------------------------------
# Gazebo + ROS integration
# ------------------------------------------------------------

echo "Installing Gazebo ${GAZEBO_DISTRO} integration..."

sudo apt install -y "ros-${ROS_DISTRO}-ros-gz"

echo "Gazebo ${GAZEBO_DISTRO}: OK"
echo

# ------------------------------------------------------------
# rosdep
# ------------------------------------------------------------

echo "Configuring rosdep..."

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
    sudo rosdep init
fi

rosdep update

echo "rosdep: OK"
echo

# ------------------------------------------------------------
# Python virtual environment
# ------------------------------------------------------------

VENV="${PROJECT_ROOT}/.venv"

echo "Configuring Python virtual environment..."

if [[ ! -d "${VENV}" ]]; then
    python3 -m venv "${VENV}"
fi

source "${VENV}/bin/activate"

python -m pip install --upgrade pip

if [[ -f "${PROJECT_ROOT}/requirements.txt" ]]; then
    python -m pip install -r "${PROJECT_ROOT}/requirements.txt"
fi

deactivate

echo "Python environment: OK"
echo

# ------------------------------------------------------------
# ROS workspace
# ------------------------------------------------------------

ROS_WS="${PROJECT_ROOT}/ros2_ws"

mkdir -p "${ROS_WS}/src"

echo "ROS workspace: ${ROS_WS}"
echo

# ------------------------------------------------------------
# ROS environment
# ------------------------------------------------------------

ROS_SETUP="source /opt/ros/${ROS_DISTRO}/setup.bash"

if ! grep -Fxq "${ROS_SETUP}" "${HOME}/.bashrc"; then
    echo "${ROS_SETUP}" >> "${HOME}/.bashrc"
fi

# ------------------------------------------------------------
# Final verification
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Verification"
echo "=========================================="
echo

source "/opt/ros/${ROS_DISTRO}/setup.bash"

echo "ROS:"
ros2 --version

echo
echo "Gazebo:"
gz sim --version

echo
echo "Python:"
python3 --version

echo
echo "GCC:"
gcc --version | head -n 1

echo
echo "CMake:"
cmake --version | head -n 1

echo
echo "=========================================="
echo " Setup complete"
echo "=========================================="
echo
