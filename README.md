[![Build Status](https://travis-ci.org/tseemann/injecta.svg?branch=master)](https://travis-ci.org/tseemann/injecta)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Don't judge me](https://img.shields.io/badge/Language-Perl_5-steelblue.svg)

# injecta
Insert genes into genomes to aid synthetic test data generation

## Introduction

When testing software that incorporates some form of gene or sequence 
detection it is desirable to generate synthetic data with known ground
truth.

## Quick Start

```
% injecta --version
injecta 0.1.2

```

## Installation

### Conda
Install [Conda](https://conda.io/docs/) or [Miniconda](https://conda.io/miniconda.html):
```
conda install -c conda-forge -c bioconda -c defaults injecta # COMING SOON
```

### Homebrew
Install [HomeBrew](http://brew.sh/) (Mac OS X) or [LinuxBrew](http://linuxbrew.sh/) (Linux).
```
brew install brewsci/bio/injecta # COMING SOON
```

### Source
This will install the latest version direct from Github.
You'll need to add the injecta `bin` directory to your `$PATH`,
and also ensure all the [dependencies](#Dependencies) are installed.
```
cd $HOME
git clone https://github.com/tseemann/injecta.git
$HOME/injecta/bin/injecta --help
```

## Dependencies

* `perl` >= 5.26

## License

injecta is free software, released under the
[GPL 3.0](https://raw.githubusercontent.com/tseemann/injecta/master/LICENSE).

## Issues

Please submit suggestions and bug reports to the
[Issue Tracker](https://github.com/tseemann/injecta/issues)

## Author

[Torsten Seemann](https://twitter.com/torstenseemann)
