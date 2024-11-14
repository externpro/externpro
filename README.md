# externpro

externpro is a collection of scripts, docker-related files, and cmake that provide foundational
support for any project wishing to leverage public [buildpro](https://github.com/externpro/buildpro)
images and third-party development packages built using externpro

## Table of Contents
- [using externpro](#using-externpro)
- [foundations](#foundations)
- [legacy externpro](#legacy-externpro)
- [notes](#notes)
  - [X11 forwarding](#X11-forwarding)

## using externpro

optimally externpro is added to any project as a submodule to the path `.devcontainer`
```
git submodule add https://github.com/externpro/externpro .devcontainer
```
symbolic links can be added to point to the `compose.*.[sh|yml]` file pair suitable for the project
```
ln -s .devcontainer/compose.bld.sh docker-compose.sh
ln -s .devcontainer/compose.bld.yml docker-compose.yml
```
`./docker-compose.sh -h` displays a help message showing usage and options

## foundations

externpro makes heavy use of cmake's
[ExternalProject](https://cmake.org/cmake/help/latest/module/ExternalProject.html) module -- see
[Building External Projects with CMake 2.8](https://www.kitware.com/main/wp-content/uploads/2016/01/kitware_quarterly1009.pdf)
for a good overview of the module when it was first introduced

## legacy externpro

there is a legacy externpro project at [smanders/externpro](https://github.com/smanders/externpro)
that creates a bundled package of several third-party
[projects](https://github.com/smanders/externpro/blob/master/projects/README.md) in tar.xz
[releases](https://github.com/smanders/externpro/releases) -- smanders/externpro will eventually be
phased out and archived as work is done to move these projects to build standalone and host their
devel packages as github release assets

## notes

### X11 forwarding
* if you're running `./docker-compose.sh` on a remote system you've connected to via `ssh -X` or `ssh -Y`
  the [denv.sh](denv.sh) script should automatically detect this case and will do additional
  configuration and populate environment variables so that X display from the running container will (hopefully)
  work as expected
* NOTE: the `-bld` images include the `xeyes` package, which can be run (`$ xeyes &`) from the
  container to verify X11 forwarding is working as expected
* TIP: if you get a "can't open display" error trying to run X applications, you may need
  to change the `X11UseLocalhost` option in `/etc/ssh/sshd_config` to `no` (and restart sshd)
