file = expanduser("~")*"/Documents/nkOperationalSecurity/data/nesta_case118_ieee_nk.m"
data = PowerSystems.parse_matpower(file)
ps_dict = PowerSystems.pm2ps_dict(data)
nodes118,generators118,storage118, branches118, loads118, loadZones118, shunts118 = PowerSystems.ps_dict2ps_struct(ps_dict)