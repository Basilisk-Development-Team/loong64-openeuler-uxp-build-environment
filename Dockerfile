# This is only intended to be ran on Loongarch64.
# It may or may not work on x86_64/aarch64.
# Users on those architectures are recommended to use our Oracle Linux 8 container instead.
FROM loongarch64/openeuler:24.03-LTS

# Hard code LLVM version so we can update with just one line edit.
# OpenEuler provides LLVM 20 packages but they are broken break so we just stick with LLVM 19 here.
ENV LLVM_VERSION=19

# Switch to a faster US-based mirror. Also make sure we're running the latest SP for the OS.
RUN sed -i 's/repo\.openeuler\.org\/openEuler-24\.03-LTS/mirrors\.ocf\.berkeley\.edu\/openeuler\/openEuler-24\.03-LTS-SP3/g' /etc/yum.repos.d/openEuler.repo
RUN dnf upgrade -y

# Install build dependencies (some of these might not be needed)
RUN dnf install -y llvm-toolset-${LLVM_VERSION} zlib-devel libffi-devel git \
    patch openssl-devel readline-devel sqlite-devel bzip2-devel unzip m4 \
    gtk2-devel gtk3-devel dbus-glib-devel pulseaudio-libs-devel alsa-lib-devel \
    libXt-devel GConf2-devel mesa-libGL-devel yasm cmake

# Create symlinks to simplify LLVM versioning
RUN for tool in clang clang++ llvm-ar llvm-nm llvm-ranlib ld.lld; do \
    ln -s /usr/bin/${tool}-${LLVM_VERSION} /usr/local/bin/${tool}; \
done

# Install python 2 (TODO: remove this when build system is fully Python 3)
ENV PYENV_ROOT=/opt/pyenv
RUN curl -fsSL https://pyenv.run | bash
# These env vars are needed for Python to build on loongarch64
RUN export LIBFFI_CFLAGS="$(pkg-config --cflags libffi)" && \
    export LIBFFI_LIBS="$(pkg-config --libs libffi)" && \
    export CPPFLAGS="$LIBFFI_CFLAGS" && \
    export CFLAGS="$LIBFFI_CFLAGS" && \
    export LDFLAGS="$LIBFFI_LIBS" && \
    CONFIGURE_OPTS="--build=loongarch64-unknown-linux-gnu" PYTHON_CONFIGURE_OPTS="--with-system-ffi" /opt/pyenv/bin/pyenv install 2.7.18
# Symlink needed so UXP picks up python
RUN ln -s /opt/pyenv/versions/2.7.18/bin/python2 /usr/local/bin/python2.7