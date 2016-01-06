# Example Python Repository

## Getting Started

Install [virtualenv](https://virtualenv.readthedocs.org/) and create a new environment:

```
virtualenv env
```

Activate the environment on Linux or OS X:

```
. env/bin/activate
```

Or Windows:

```
.\env\scripts\activate
```

Install the package and its requirements:

```
pip install -r dev-requirements.txt
```

### Running Tests

Run the tests with the [tox](https://tox.readthedocs.org/) command:

```
tox
```

### Uploading to PyPi

```
python setup.py register -r internal
python setup.py sdist upload -r internal
```
