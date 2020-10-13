import pandas as pd
import matplotlib.pyplot as plt
times=pd.read_csv('of.SUM.LU_Read_TransRate.csv.CL3-C.csv',index_col='time')
times.plot(y=times.columns)
plt.show()
