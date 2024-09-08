# FCOS Packer Template

## Prerequisite
* [Oracle VirtualBox](https://virtualbox.org)
* [HashiCorp Packer](https://packer.io)
* [Podman](https://podman.io) or [Docker](https://docker.com)

## Template Usage

### 1. Adjust template configuration


### 2. Generate Ignition JSON from Butane YAML
**Podman:**
```pwsh
> cd template
> podman run -i --rm -v ${PWD}:/pwd -w /pwd quay.io/coreos/butane:release -d . --pretty --strict config.bu > config.ign
```

**Docker:**
```pwsh
> cd template
> docker run -i --rm -v ${PWD}:/pwd -w /pwd quay.io/coreos/butane:release -d . --pretty --strict config.bu > config.ign
```

### 3. Run Packer
```pwsh
> packer build .
```