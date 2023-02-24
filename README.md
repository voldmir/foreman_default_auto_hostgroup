# Foreman Default Auto Hostgroup

Plugin to auto add hostgroup to host.

## Installation

msgfmt -o ./LC_MESSAGES/foreman_default_auto_hostgroup.mo ./foreman_default_auto_hostgroup.po

See Foreman's [plugin installation documentation](https://theforeman.org/plugins/#2.Installation).

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | -------------: |
| ~> 1.24         |          0.1.2 |
| ~> 1.24         |          1.0.0 |
| ~> 1.24         |          1.0.1 |

Авто добавление хоста в группу на основании факта содержащего значение "canonicalname" "Organizational Unit" из "Active Directory"
Настраиваемые значения: 
    наименование факта;
    хосты для исключения (используется Regex);
    Группа по умолчанию;
    Активация плагина.
    