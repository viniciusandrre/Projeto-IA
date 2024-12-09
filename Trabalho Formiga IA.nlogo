; === INSTRUÇÕES ===
; === DEFINIÇÃO DE VARIÁVEIS ===

globals [
  raining?            ;estado global:indica chuva ou nao
  rain-intensity      ;intensidade da chuva
  sunny?              ;estado global do sol
  sun-intensity       ;intensidade do sol
  climate-duration    ;duracao do clima
]

; Variáveis dos patches (espaço onde as formigas se movem)
patches-own [
  chemical             ; quantidade de feromônio neste patch
  food                 ; quantidade de comida neste patch (0, 1 ou 2)
  nest?                ; verdadeiro se o patch é parte do ninho, falso caso contrário
  nest-scent           ; valor numérico maior próximo ao ninho, usado para orientar as formigas
  food-source-number   ; identifica as fontes de alimento (1, 2 ou 3)
  predator-pheromone   ; feromonio
]

; Variáveis das tartarugas (formigas e predadores)
turtles-own [
  life               ; Quantidade de vida da formiga ou predador
  carrying-food?     ; Indica se a formiga está carregando comida
  predator-alert     ; Indica se a formiga está alertando sobre um predador
]

; === PROCEDIMENTOS DE CONFIGURAÇÃO ===

to setup
  clear-all                            ; limpa o mundo e reinicia a simulação
  set sunny? false                      ; sol ativo no inicio
  set raining? false                   ; sem chuva no inicio
  set sun-intensity 50                 ; intensidade inicial do sol
  set rain-intensity 50                ; ; intensidade inicial da chuva
  set climate-duration 50
  setup-sun
  set-default-shape turtles "bug"       ; define o formato das formigas como "inseto"
  create-turtles population [           ; cria formigas com base no valor do slider 'population'
    set size 1                          ; aumenta o tamanho para melhor visualização
    set color red                       ; vermelho indica que não está carregando comida
    set life 3                          ; vida inicial formiga
    set predator-alert false            ;não alerta inicialmete o predador
  ]
  create-predators
  setup-patches                         ; chama o procedimento para configurar os patches
  reset-ticks                           ; reinicia o contador de tempo da simulação
end

to create-predators
  create-turtles 1                      ; Cria um predador
  [set size 11                          ; tamanho
   set color brown                      ; cor
   set label "tamandua"                 ; nome do predador
   setxy -1 21                          ; posição do predador
   set life 100                         ; vida inicial predador(Tamanduá)
  ]
  ;;Cria o Garfanhoto
  create-turtles 1                      ; Cria um predador
  [set size  4                          ; tamanho
   set color green                      ;cor
   set label "gafanhoto"                ;nome do predador
   setxy 20 -22                         ;posição do predador
   set life 15                          ;vida inicial predador(Gafanhoto)
  ]
end

to setup-patches
  ask patches [
    setup-nest                          ; configura o ninho nos patches
    setup-food                          ; configura as fontes de alimento
    recolor-patch                       ; define as cores dos patches para visualização
  ]
end

to setup-nest  ; procedimento dos patches
  set nest? (distancexy 0 0) < 5         ; define patches dentro de um raio de 5 unidades como ninho
  set nest-scent 200 - distancexy 0 0    ; valor maior próximo ao ninho, decrescendo com a distância
end

to setup-food  ; procedimento dos patches
  ; Configura três fontes de alimento em posições específicas
  if (distancexy (0.6 * max-pxcor) 0) < 5 [
    set food-source-number 1
  ]
  if (distancexy (-0.6 * max-pxcor) (-0.6 * max-pycor)) < 5 [
    set food-source-number 2
  ]
  if (distancexy (-0.8 * max-pxcor) (0.8 * max-pycor)) < 5 [
    set food-source-number 3
  ]
  ; Se o patch faz parte de uma fonte de alimento, atribui uma quantidade de comida (1 ou 2)
  if food-source-number > 0 [
    set food one-of [1 2]
  ]
end

to recolor-patch
  ifelse predator-pheromone > 0 [
    set pcolor scale-color yellow predator-pheromone 0.1 5 ; Feromônio do predador em amarelo
  ] [
    ifelse food > 0 [
     ; Patches com comida são coloridos de acordo com a fonte
      if food-source-number = 1 [ set pcolor cyan ]
      if food-source-number = 2 [ set pcolor sky ]
      if food-source-number = 3 [ set pcolor blue ]
    ] [
      ifelse nest? [
         set pcolor violet ; Patches do ninho em violeta
       ] [
         ifelse chemical > 0 [
           set pcolor scale-color green chemical 0.1 5 ; Feromônio das formigas em verde
         ] [
           set pcolor black ; Patches sem feromônio, comida ou ninho ficam pretos
        ]
      ]
    ]
  ]
end


; === PROCEDIMENTOS PRINCIPAIS ===

to go
  switch-climate       ; Alterna entre sol e chuva
  adjust-sun-visuals   ; Ajusta visualmente o sol
  sunny-effects        ; Aplica efeitos do sol
  toggle-rain
  create-rain
  move-rain
  evaporate-rain
  ask turtles with [shape != "sun"] [
    if who >= ticks [ stop ]             ; sincroniza a saída das formigas do ninho com o tempo
    ifelse color = red [
      look-for-food                      ; procura por comida se não estiver carregando
    ] [
      return-to-nest                     ; retorna ao ninho se estiver carregando comida
    ]
    wiggle                               ; movimento aleatório para simular procura
    fd 1                                 ; move-se para frente
  ]
  pheromone-diffusion ; Difusão e evaporação dos feromônios
  recolor-patches
  predator-attack    ; Predadores atacam formigas
  ant-defense        ; Formigas defendem-se e avisam outra
  tick                                  ; avança o contador de tempo da simulação
end

; === COMPORTAMENTOS DAS FORMIGAS ===

to look-for-food  ; procedimento das formigas
  if food > 0 [
    set color orange + 1                ; muda a cor para indicar que está carregando comida
    set food food - 1                   ; reduz a quantidade de comida no patch
    rt 180                              ; vira 180 graus para retornar ao ninho
    stop                                ; finaliza o procedimento atual
  ]
  if (chemical >= 0.05) and (chemical < 2) [
    uphill-chemical                     ; segue o rastro de feromônio
  ]
end

to return-to-nest  ; procedimento das formigas
  ifelse nest? [
    set color red                       ; deposita a comida e muda a cor para não carregando
    rt 180                              ; vira 180 graus para sair novamente
  ] [
    set chemical chemical + 60          ; deposita feromônio no caminho de volta
    uphill-nest-scent                   ; move-se em direção ao ninho seguindo o gradiente
  ]
end

to ant-defense                           ;defesa/ataque das formigas
  ask turtles with [color = red or color = orange] [
    let predator one-of turtles in-radius 1 with [label = "tamandua" or label = "gafanhoto"]
    if predator != nobody [
      ask predator [
        set life life - 1                ;diminui a vida de -1 em -1
        if life <= 0 [die]              ;verifica a morte ou nao do predaor
      ]
      set predator-alert true           ;alerta do predador
    ]
  ]
end

; === COMPORTAMENTO DOS PREDADORES ===

to predator-attack                       ;ataque do predador
  ask turtles with [label = "tamandua" or label = "gafanhoto"] [
    let prey one-of turtles in-radius 1 with [color = red or color = orange]
    if prey != nobody [
     ask prey [
       set life life - 3                  ;mata a formiga de forma instantanea
        if life <= 0 [die]                ;verifica a morte ou nao da formiga
      ]
     set predator-alert true             ;alerta da presa
    ]
  ]
end


; === MOVIMENTAÇÃO E ORIENTAÇÃO ===

to uphill-chemical  ; procedimento das formigas
  let scent-ahead chemical-scent-at-angle 0
  let scent-right chemical-scent-at-angle 45
  let scent-left chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead) [
    ifelse scent-right > scent-left [
      rt 45                              ; vira 45 graus à direita
    ] [
      lt 45                              ; vira 45 graus à esquerda
    ]
  ]
end

to uphill-nest-scent  ; procedimento das formigas
  let scent-ahead nest-scent-at-angle 0
  let scent-right nest-scent-at-angle 45
  let scent-left nest-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead) [
    ifelse scent-right > scent-left [
      rt 45                              ; vira 45 graus à direita
    ] [
      lt 45                              ; vira 45 graus à esquerda
    ]
  ]
end

to pheromone-diffusion
    diffuse chemical (diffusion-rate / 100)
    diffuse predator-pheromone 0.1
    ask patches [
      set chemical chemical * (100 - evaporation-rate) / 100
      set predator-pheromone predator-pheromone * 0.9
  ]
end

to recolor-patches
  ask patches [
    recolor-patch                        ;atualiza a cor
  ]
end

to wiggle  ; procedimento das formigas
  rt random 40                           ; vira um ângulo aleatório à direita
  lt random 40                           ; vira um ângulo aleatório à esquerda
  if not can-move? 1 [ rt 180 ]          ; se não puder se mover, vira 180 graus
end

; === Clima ===

to create-rain                          ;criando a chuva
  if raining? and not sunny? [
    create-turtles rain-intensity [
      set size 0.3                      ; tamanho
      set shape "raindrop"              ; gota importada da biblioteca e renomeada
      set color blue                    ; cor
      setxy random-xcor max-pycor       ; chuva caindo no mapa
      set heading 100                   ; de onde cai
    ]
  ]
end

to move-rain                           ;  movimentando a chuva
  ask turtles with [shape = "raindrop"] [
    fd 1
    if ycor <= min-pycor [
      ask patch-here [
        if pcolor != blue [set pcolor blue]
      ]
      die
    ]
  ]
end

to evaporate-rain                    ; desaparecendo com as gotas
  ask patches with [pcolor = blue] [
    set pcolor scale-color black random 10 0 10
  ]
end

to toggle-rain                 ; chance de chover
  if random 100 < 40 [         ; 20% de chance de mudar o estado a cada tick
    set raining? not raining?  ; Alterna entre true e false
  ]
end

to setup-sun                  ; criando o sol
  create-turtles 1 [
    set size 5
    set color yellow
    set shape "sun"
    setxy 23 23
  ]
end

to switch-climate
  if climate-duration = 0 [
    ; Alterna entre sol e chuva
    ifelse sunny? [
      set sunny? false
      set raining? true
    ] [
      set sunny? true
      set raining? false
    ]

    ; Define nova duração entre 50 e 100 ticks
    set climate-duration random 50 + 50

    ; Ajusta intensidade do sol ou zera durante chuva
    ifelse sunny? [
      set sun-intensity random 50 + 50
    ] [
      set sun-intensity 0
    ]

    ; Ajusta a cor do sol com base no clima
    ask turtles with [shape = "sun"] [
      ifelse sunny? [
        set color yellow  ; Sol fica amarelo
      ] [
        set color gray    ; Sol fica cinza
      ]
    ]
  ]

  ; Reduz o contador de duração
  set climate-duration climate-duration - 1
end



to sunny-effects
  if sunny? [
    ask patches with [pcolor = blue] [
      set pcolor scale-color black (sun-intensity / 10) 0 10 ; Evaporação proporcional à intensidade do sol
    ]
  ]
end

to adjust-sun-visuals
  ask turtles with [label = "☀"] [
    set size (sun-intensity / 20) + 2 ; Tamanho proporcional à intensidade
    ifelse sunny? [
      set color yellow
    ] [
      set color gray
    ]
  ]
end



; === FUNÇÕES AUXILIARES ===

to-report nest-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]             ; se não houver patch, retorna 0
  report [nest-scent] of p               ; retorna o valor de 'nest-scent' do patch
end

to-report chemical-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]             ; se não houver patch, retorna 0
  report [chemical] of p                 ; retorna o valor de 'chemical' do patch
end

; === INFORMAÇÕES ADICIONAIS ===

; Este modelo simula o comportamento de formigas em busca de alimento e retorno ao ninho.
; As formigas deixam rastros de feromônio para guiar outras formigas às fontes de alimento.
; O feromônio evapora e difunde ao longo do tempo, criando um gradiente que as formigas seguem.

; === COPYRIGHT ===

; Copyright 1997 Uri Wilensky.
; Veja a aba 'Info' para o copyright completo e licença.
@#$#@#$#@
GRAPHICS-WINDOW
210
10
881
682
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

SLIDER
782
56
954
89
population
population
50
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
824
127
996
160
diffusion-rate
diffusion-rate
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
806
231
978
264
evaporation-rate
evaporation-rate
0
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
1269
113
1332
146
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
0

BUTTON
1266
208
1329
241
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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
