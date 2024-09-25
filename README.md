# C Module Generator

## Requirements

1. Powershell 7

The cmdlet uses constructs that aren't compatible with Powershell 5. That is a
mistake I made early and that I chose to live with.

## Using

### Quick start

1. Edit `*.templ` files to match your personal prefererences or that of your organization.
1. Copy `proj_conf.ps1` to your project's root.
1. Edit `proj_conf.ps1` to match your project's attributes.
1. Import `CModuleGen.psm` using `Import-Module`.
1. To create a new module, run `New-CModule -Name "<Capitalized Module Name>"`.
1. To create include a test file, add the flag `-UnitTest`.
1. To create only a single file, use the `-Only` parameter (hint: cycle through options using <TAB>).

### Notes on module names

Assuming the `-ModuleName` parameter argument is `"My Module"` and assuming
no edits to the cmdlet or to the templates:

- The module _Doxygen_ group will be `My Module`.
- The files, if generated, will be `module_name.h`, `module_name.c` and `test_module_name.c`.
- The include guard will be `MODULE_NAME_H_`.
