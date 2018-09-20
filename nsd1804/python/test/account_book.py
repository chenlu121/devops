import time
all_money=[1000]
def income():
    try:
        money=int(input('请输入金额'))
    except (ValueError,ZeroDivisionError):
        print('无效输入')
    else:
        state=input('说明：')
        all_money.append(money)
    finally:
        write_date(all_money[-1],state)
def spending():
    try:
        money=int(input('请输入金额'))
    except (ValueError,ZeroDivisionError):
        print('无效输入')
    else:
        money=money*(-1)
        state=input('说明：')
        all_money.append(money)
    finally:
        write_date(all_money[-1],state)
def view_account():
    with open('/root/account.txt') as fobj:
        fobj.read()
def write_date(money,state):
    date = time.ctime()
    list=[date,money,state]
    with open('/root/account.txt','a') as fobj:
        fobj.write(list)
def manual():
    cmds={'0':income,'1':spending,'2':view_account}
    display="""
[0]收入
[1]支出
[2]查看
[3]退出    
请输入(0/1/2/3):
"""
    choice=input(display).rstrip()[0]
    if not choice  in '0123':
        print('输入错误，请重新输入.')
    cmds[choice]()
if __name__ == '__main__':
    manual()