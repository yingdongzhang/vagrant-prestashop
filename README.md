## Vagrant Prestashop
This is a vagrant template for building a Prestashop development environment.

This template boots up two Prestashop sites, one with sample data, one without sample data.

### Development Environment
The development environment is based on vagrant, and [this project](https://github.com/nurelm/prestashop_vagrant), so big thanks to [nurelm](https://github.com/nurelm) for the template.

In order to run you will need to have VirtualBox and vagrant installed on your local development machine.

NOTE: The first time you run `vagrant up` it may take some time to download the required baseboxes etc.

#### Usage

+ Access the virtual machine directly using vagrant ssh
+ When you're done vagrant halt

To access test site with sample data:

+ In your browser, head to 127.0.0.1:8080
+ Prestashop CMS is accessed at 127.0.0.1:8080/admin1234
+ User: admin@myshop.com Password: password

To access test site without sample data:

+ In your browser, head to 127.0.0.1:8081
+ Prestashop CMS is accessed at 127.0.0.1:8081/admin1234
+ User: admin@myshop.com Password: password

### PrestaShop Plugin Development

### Vagrant Basebox
The vagrant file used for this project can be found here: https://github.com/nurelm/prestashop_vagrant

If you find any issues with this vagrant file please fork and issue a pull request with your fixes to help out the author.

## Development Notes
### Project Structure

### Config Changes
PHP Error display is enabled during provisioning.

PrestaShop caching is disabled during provisioning.

PrestaShop Template Force Compilation is enabled during provisioning.

PrestaShop DEV_MODE is enabled during provisioning.