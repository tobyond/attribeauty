## [Unreleased]

## [0.4.4] - 2024-06-26

- get `default:` working. Not expecting to use them since db will handle that, but nice to have?

## [0.4.3] - 2024-06-25

- allow certain values with `allow` option

## [0.4.2] - 2024-06-25

- getting and setting vals in params

## [0.4.1] - 2024-06-25

- Global default_args in accept, to apply your conditions to all attributes

## [0.4.0] - 2024-06-25

- Breaking change:
- `:allow_nil`, and `:allow_empty` have been replaced with `:exclude_if`
- see readme for details

## [0.3.4] - 2024-06-24

- tiny refactor

## [0.3.3] - 2024-06-24

- handle nil in types. Big refactor

## [0.3.2] - 2024-06-24

- added accept! method to raise error if "required's" are missing

## [0.3.1] - 2024-06-22

- added container to exclude the "head" param

## [0.3.0] - 2024-06-21

- Experimental params coercion
- No documentation yet, but tests passing

## [0.1.0] - 2023-08-09

- Initial release
