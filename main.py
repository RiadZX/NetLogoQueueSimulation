import json


# def convert_to_float(num):
# if type(num) == float:
#     return num
# if type(num) == int:
#     return float(num)
# if type(num) == str:
#     return float(num.replace(',', '.'))


# read json file
with open('workingDataFinal.json') as f:
    runs = json.load(f)

allRuns = []

listData = []


def find(lst, key, value):
    for i, dic in enumerate(lst):
        if dic[key] == value:
            return i
    return -1


for i in range(len(runs)):  # go trough all runs
    # checkif current run is in the list of all runs
    if str(runs[i][0]) in str(allRuns):

        # get index of where the run is in the list
        if find(allRuns, "run", runs[i][0]) != -1:
            index = find(allRuns, "run", runs[i][0])
            allRuns[index]["amount"] += 1
            allRuns[index]["total"] += runs[i][1]
            allRuns[index]["average"] = allRuns[index]["total"] / \
                allRuns[index]["amount"]

    else:
        allRuns.append(
            {"run": runs[i][0], "average": runs[i][1], "amount": 1, "total": runs[i][1]})
        print("yes")


# write json file
with open('workingDataFinal2.json', 'w') as f:
    json.dump(allRuns, f)
