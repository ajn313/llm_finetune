import pandas as pd
import json
df_code = pd.read_csv ('Verilog_bigquery_GitHub.csv')
with open('verilog_dataset.json','a') as f:
    for row in df_code['text'].values:
        dic={"text":str(row)}
        ob=json.dumps(dic)
        f.write(ob)
        f.write('\n')
f.close()