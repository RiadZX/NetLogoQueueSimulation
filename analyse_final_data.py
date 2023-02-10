import json
with open('workingDataFinal2.json') as f:
    runs = json.load(f)

# sort json file by value of key "run"
runs.sort(key=lambda x: x["average"])
print(runs[0])
