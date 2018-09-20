# -*- coding: utf-8 -*-
import time,pickle
all_money=[1000]
def income():
    try:
        money=int(input(u'请输入金额'))
    except (ValueError,ZeroDivisionError):
        print(u'无效输入')
    else:
        state=input(u'说明：')
        all_money.append(money)
    finally:
        write_date(all_money[-1],state)
def spending():
    try:
        money=int(input(u'请输入金额'))
    except (ValueError,ZeroDivisionError):
        print(u'无效输入')
    else:
        money=money*(-1)
        state=input(u'说明：')
        all_money.append(money)
    finally:
        type(all_money[-1])
        write_date(all_money[-1],state)
def view_account():
    with open('./account.txt','b') as fobj:
        print(pickle.load(fobj))
def write_date(insert_data,state):
        date = time.ctime()
        list=(date,insert_data,state)
        with open('./account.txt','ab') as fobj:
             pickle.dump(list,fobj,0)
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
#    manual()
    income()