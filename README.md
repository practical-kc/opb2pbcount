[![Crates.io Version](https://img.shields.io/crates/v/opb2pbcount)](https://crates.io/crates/opb2pbcount)

# opb2pbcount

> Converter for the OPB format to be used by pbcount

This tool takes an OPB file and modifies it in such a way that it can be consumed by [pbcount][pbcount].

The following changes are made to the formula:
 - variables are put in the form of `x1`, `x2`, ...
 - constraints are changed to only `=` or `>=`
 - fails on constraint type `!=`

## Installation

### [Nix][nix]

```
nix build github:practical-kc/opb2pbcount
```

### Cargo

```
cargo build --release
```

## Usage

```
opb2pbcount --input file.opb --output output.opb
```

[pbcount]: https://github.com/grab/pbcount
[nix]: https://nixos.org
