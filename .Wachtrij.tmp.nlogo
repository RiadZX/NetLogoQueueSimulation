globals[
  customersWaiting0
  customersWaiting1
  customersWaiting2
  customersWaiting3
  queueLimit
  customersDone
  averageWaitingAction1
  averageWaitingAction2
  averageWaitingAction3
  actionAccepted0
  actionAccepted1
  actionAccepted2
  actionAccepted3
  tickspercustomer
  count1
  count2
  count3
breakLength
  worker0Break
  worker1Break
  worker2Break
  worker3Break
]

breed[customers customer]
breed[workers worker]

customers-own[
  location
  action
  waitedTime
  actionActive
  actionTime
  ticks-on-patch
  timeInQueue


]

workers-own [
  location ;; queue
  onBreak


]

to setup
  clear-all
  reset-ticks
  set tickspercustomer 3
  set queueLimit 14
  set worker0Break false
  set worker1Break false
  set worker2Break false
  set worker3Break false
  ask patches [
    set pcolor 33
  ]
  ask patches with [(pxcor + pycor) mod 2 = 0]
  [
    set pcolor  35
  ]

  ask patches with [pycor = 7]
  [
    set pcolor 3
  ]


  create-workers 4

  ask workers[
    set ycor 8
    set shape "person service"
    set breakLength 15
  ]
  ask worker 0[
    set location 0
    set xcor -3
    set plabel actionAcceptedList0
  ]
  ask worker 1[
    set location 1
    set xcor -1
    set plabel actionAcceptedList1
  ]
  ask worker 2[
    set location 2
    set xcor 1
    set plabel actionAcceptedList2
  ]
  ask worker 3[
    set location 3
    set xcor 3
    set plabel actionAcceptedList3
  ]

  ;;location -1 = entrance
  ;;location 0 = queue 0
  ;;location 1 = queue 1
  ;;location 2 = queue 2
  ;;location 3 = queue 3
  ;;location 4 = done, exit

  ;;action 1 = 2-5
  ;;action 2 = 3-10
  ;;action 3 = 5-20
  convert_actions
  check_if_setup_valid
end

to go
  if count1 < 2 or count2 < 2 or count3 < 2[stop]
  if ticks > 800 [stop]
  if  remainder ticks tickspercustomer = 0 and ticks < 500[
    create-customers 1 [
      set shape "person business"
      set xcor -6
      set ycor -8
      set location -1
      set actionActive 0
      set ticks-on-patch 0
      set timeInQueue 0
      assign-random-action

    ]

  ]

  calculate_waiting
  ask customers
  [
    if location != 4[
      ifelse location = -1
      [go-to-line]
      [move-in-line]
    ]
  ]
  ask workers [
   take_break
  ]
  calculate_average
  tick
end

to assign-random-action
  let randomnumber random 100
  if randomnumber > 95[set action 3  set actionTime ((random 21) + 5)]
  if randomnumber <= 95 and randomnumber > 80 [set action 2 set actionTime ((random 11) + 3)]
  if randomnumber <= 80 [set action 1 set actionTime ((random 3) + 2)]

end

to take_break
  ;;check tick range,
  ;;check if first took break
  ;; if first took break, ask second, check again etc
  ;; if didnt take break and in range, take break xx tick
  ;; if done with break, onBreak off, took break on.

  if ticks = 240[
    ask worker 0 [
    set onBreak true
    set shape "x"
     set worker0Break true
    ]
  ]
  if ticks =  240 + breakLength[
    set worker0Break false
    ask workers [set onBreak false set shape "person service"]
    ask worker 1 [
      set worker1Break true
    set onBreak true
      set shape "x"
    ]
  ]
  if ticks = 240 + breakLength * 2[
ask workers [set onBreak false set shape "person service"]
    set worker1Break false
    ask worker 2 [
    set onBreak true
      set shape "x"
      set worker2Break true
    ]
  ]
  if ticks = 240 + breakLength * 3[
ask workers [set onBreak false set shape "person service"]
    set worker2Break false
    ask worker 3 [
    set onBreak true
      set shape "x"
      set worker3Break true
    ]
  ]
  if ticks = 240 + breakLength * 4[
ask workers [set onBreak false set shape "person service"]
    set worker3Break false
  ]
end

;;customer functions
to go-to-line

  calculate_waiting
  let best [-1 9999]
;;check if worker is on break
;; if break -> dont go there

  repeat 4 [
    foreach actionAccepted0 [x ->
      if x = action [

        if last best >= customersWaiting0 [
          if customersWaiting0 < queueLimit and worker0Break = false[
            set best replace-item 0 best 0
            set best replace-item 1 best customersWaiting0
          ]
        ]
      ]
    ]
    foreach actionAccepted1 [x ->
      if x = action [
        if last best >= customersWaiting1 [
          if customersWaiting1 < queueLimit  and worker1Break = false[
            set best replace-item 0 best 1
            set best replace-item 1 best customersWaiting1
          ]
        ]
      ]
    ]
    foreach actionAccepted2 [x ->
      if x = action [
        if last best >= customersWaiting2 [
          if customersWaiting2 < queueLimit and worker2Break = false[
            set best replace-item 0 best 2
            set best replace-item 1 best customersWaiting2
          ]
        ]
      ]
    ]
    foreach actionAccepted3 [x ->
      if x = action [
        if last best >= customersWaiting3 [
          if customersWaiting3 < queueLimit and worker3Break = false[
            set best replace-item 0 best 3
            set best replace-item 1 best customersWaiting3
          ]
        ]
      ]
    ]
  ]
  if first best = 0[
    set xcor -3
    set location first best
    set ycor 6 - customersWaiting0

  ]
  if first best = 1[
    set xcor -1
    set location first best
    set ycor 6 - customersWaiting1
  ]
  if first best = 2[
    set xcor 1
    set location first best
    set ycor 6 - customersWaiting2
  ]
  if first best = 3[
    set xcor 3
    set location first best
    set ycor 6 - customersWaiting3
  ]
end

to move-in-line
  set timeInQueue timeInQueue + 1
  ;; check if worker in your queue is on queue
  let pauseBreak false
  if xcor = -3 and worker0Break = true [set pauseBreak true]
  if xcor = -1 and worker1Break = true [set pauseBreak true]
  if xcor = 1 and worker2Break = true [set pauseBreak true]
  if xcor = 3 and worker3Break = true [set pauseBreak true]

  ifelse ycor + 2 = 8 pauseBreak = false[

    set actionActive true

    ifelse ticks-on-patch >= actionTime
    [
      set location 4
      set xcor 6
      set ycor -8
      set hidden? true
    ]
    [
      set ticks-on-patch ticks-on-patch + 1
    ]

  ]

  [
    let main-customer-x xcor
    let main-customer-y ycor

    ifelse any? customers with [xcor = main-customer-x and main-customer-y + 1 = ycor] [][
      ask customers with [xcor = main-customer-x and ycor = main-customer-y][
        set ycor ycor + 1
      ]
  ]]

end


;;global functions
to calculate_waiting
  set customersWaiting0 count customers with [location = 0]
  set customersWaiting1 count customers with [location = 1]
  set customersWaiting2 count customers with [location = 2]
  set customersWaiting3 count customers with [location = 3]
  set customersDone count customers with [location = 4]
end

to calculate_average
  let customersaction1 count customers with [location = 4 and action = 1]
  let customersaction2 count customers with [location = 4 and action = 2]
  let customersaction3 count customers with [location = 4 and action = 3]

  ifelse (customersaction1) = 0 [][ set averageWaitingAction1 (sum [timeInQueue] of customers with [location = 4 and action = 1])/(count customers with [location = 4 and action = 1])]
  ifelse (customersaction2) = 0 [][ set averageWaitingAction2 (sum [timeInQueue] of customers with [location = 4 and action = 2])/(count customers with [location = 4 and action = 2])]
  ifelse (customersaction3) = 0 [][ set averageWaitingAction3 (sum [timeInQueue] of customers with [location = 4 and action = 3])/(count customers with [location = 4 and action = 3])]

end

to convert_actions
  let actionsstringlist0 explode actionAcceptedList0
  set actionAccepted0 read-from-list actionsstringlist0
  let actionsstringlist1 explode actionAcceptedList1
  set actionAccepted1 read-from-list actionsstringlist1
  let actionsstringlist2 explode actionAcceptedList2
  set actionAccepted2 read-from-list actionsstringlist2
  let actionsstringlist3 explode actionAcceptedList3
  set actionAccepted3 read-from-list actionsstringlist3
end

to-report explode [s]
  report map [n -> item n s] n-values (length s) [n -> n]
end
to-report read-from-list [ x ]
  report ifelse-value is-list? x
    [ map read-from-list x ]
  [ read-from-string x ]
end

to check_if_setup_valid
  foreach actionAccepted0 [x ->
    if x = 1 [set count1 count1 + 1]
    if x = 2 [set count2 count2 + 1]
    if x = 3 [set count3 count3 + 1]
  ]
  foreach actionAccepted1 [x ->
    if x = 1 [set count1 count1 + 1]
    if x = 2 [set count2 count2 + 1]
    if x = 3 [set count3 count3 + 1]
  ]
  foreach actionAccepted2 [x ->
    if x = 1 [set count1 count1 + 1]
    if x = 2 [set count2 count2 + 1]
    if x = 3 [set count3 count3 + 1]
  ]
  foreach actionAccepted3 [x ->
    if x = 1 [set count1 count1 + 1]
    if x = 2 [set count2 count2 + 1]
    if x = 3 [set count3 count3 + 1]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
244
10
731
645
-1
-1
36.85
1
10
1
1
1
0
1
1
1
-6
6
-8
8
0
0
1
ticks
165.0

BUTTON
6
10
69
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
78
10
141
43
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
9
115
67
160
Action 1
count customers with [action = 1]
17
1
11

MONITOR
4
168
62
213
Action 2
count customers with [action = 2]
17
1
11

MONITOR
4
222
62
267
Action 3
count customers with [action = 3]
17
1
11

MONITOR
6
58
76
103
customers
count customers
17
1
11

BUTTON
144
10
234
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
745
13
1161
170
customers done
time
done
0.0
500.0
0.0
500.0
true
true
"" ""
PENS
"customers" 1.0 0 -16777216 true "" "plot customersDone"

MONITOR
746
172
1160
217
customers done
customersDone
0
1
11

MONITOR
746
223
946
268
averageWaitingAction1
averageWaitingAction1
3
1
11

MONITOR
956
223
1160
268
averageWaitingAction2
averageWaitingAction2
17
1
11

MONITOR
746
274
947
319
averageWaitingAction3
averageWaitingAction3
17
1
11

INPUTBOX
91
51
227
111
actionAcceptedList0
123
1
0
String

INPUTBOX
88
118
226
178
actionAcceptedList1
123
1
0
String

INPUTBOX
88
185
227
245
actionAcceptedList2
123
1
0
String

INPUTBOX
88
252
229
312
actionAcceptedList3
123
1
0
String

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count customersDone</metric>
    <metric>count averageWaitingAction1</metric>
    <metric>count averageWaitingAction2</metric>
    <metric>count averageWaitingAction3</metric>
    <enumeratedValueSet variable="actionAcceptedList0">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;12&quot;"/>
      <value value="&quot;123&quot;"/>
      <value value="&quot;23&quot;"/>
      <value value="&quot;13&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="actionAcceptedList1">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;12&quot;"/>
      <value value="&quot;123&quot;"/>
      <value value="&quot;23&quot;"/>
      <value value="&quot;13&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="actionAcceptedList2">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;12&quot;"/>
      <value value="&quot;123&quot;"/>
      <value value="&quot;23&quot;"/>
      <value value="&quot;13&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="actionAcceptedList3">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;12&quot;"/>
      <value value="&quot;123&quot;"/>
      <value value="&quot;23&quot;"/>
      <value value="&quot;13&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
VIEW
96
160
575
786
0
0
0
1
1
1
1
1
0
1
1
1
-6
6
-8
8

@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
