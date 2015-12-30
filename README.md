# proxysql-cookbook

Generates ProxySQL configuration and starts ProxySQL in a docker container.
See https://github.com/smartboxgroup/proxysql-docker

## Supported Platforms

TODO: List your supported platforms.

## Attributes

The attributes defined by this recipe are organized under the node['proxysql'] namespace.
All ProxySQL admin and frontend configurations are managed using attributes.
Backend configurations, such as mysql servers, mysql users and sq; query rules, are managed in data bags. You can specift the databag name and section within it in attributes.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['proxysql']['databag']</tt></td>
    <td>String</td>
    <td>Where to find the backend configurations</td>
    <td><tt>proxysql</tt></td>
  </tr>
  <tr>
    <td><tt>['proxysql']['databag_section']</tt></td>
    <td>String</td>
    <td>Where to find the backend configurations inside the data bag</td>
    <td><tt>proxysql</tt></td>
  </tr>
  <tr>
    <td><tt>['proxysql']['config_file']</tt></td>
    <td>String</td>
    <td>Where to place the generated ProxySQL config file, note that the folder containing this file will be mounted in the docker container</td>
    <td><tt>/etc/proxysql/proxysql.cnf</tt></td>
  </tr>
</table>

## Usage

### proxysql::default

Include `proxysql` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[proxysql::default]"
  ]
}
```

## License and Authors

Author:: Smartbox (si-opex@smartbox.com)
