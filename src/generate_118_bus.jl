file = expanduser("~")*"/Documents/nkOperationalSecurity/data/nesta_case118_ieee_nk.m"
data = PowerSystems.parse_matpower(file)
ps_dict = PowerSystems.pm2ps_dict(data)
buses,generators,storage, branches, loads, loadZones, shunts = PowerSystems.ps_dict2ps_struct(ps_dict)