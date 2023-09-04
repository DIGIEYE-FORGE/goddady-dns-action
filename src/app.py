import goddady as gd


if __name__ == "__main__" :
    print('Start creating dns record into Goddady')
    status = gd.updateDomainRecord(host=gd.HOSTNAME,ip_address=gd.IP_ADDRESS)
    print(f"::set-output name=status::{status}")