; === INSTRUÇÕES ===
; === DEFINIÇÃO DE VARIÁVEIS ===

globals [
  raining?            ;estado global:indica chuva ou nao
  rain-intensity      ;intensidade da chuva
  sunny?              ;estado global do sol
  sun-intensity       ;intensidade do sol
  climate-duration    ;duracao do clima
  max-ant-age         ;idade maxima antes de morrer
  births-per-tick     ;numero de formigas nascidas no tick atual
  total-food-collected ; quantidade total de comida coletada
]

; Variáveis dos patches (espaço onde as formigas se movem)
patches-own [
  chemical             ; quantidade de feromônio neste patch
  food                 ; quantidade de comida neste patch (0, 1 ou 2)
  nest?                ; verdadeiro se o patch é parte do ninho, falso caso contrário
  nest-scent           ; valor numérico maior próximo ao ninho, usado para orientar as formigas
  food-source-number   ; identifica as fontes de alimento (1, 2 ou 3)
  predator-pheromone   ; feromonio
  food-value          ; valor nutricional do alimento neste patch
]

; Variáveis das tartarugas (formigas e predadores)
turtles-own [
  ant-type           ; tipo de formiga
  life               ; Quantidade de vida da formiga ou predador
  carrying-food?     ; Indica se a formiga está carregando comida
  predator-alert     ; Indica se a formiga está alertando sobre um predador
  age                ; idade da formiga
]

; === PROCEDIMENTOS DE CONFIGURAÇÃO ===

to setup
  clear-all                            ; limpa o mundo e reinicia a simulação
  set births-per-tick 0                ; Inicializa como 0 os nascimento por tick
  set total-food-collected 0           ; Total de comida coletada
  set max-ant-age 70;                  ; idade maxima da formiga como 70
  set sunny? false                     ; sol ativo no inicio
  set raining? false                   ; sem chuva no inicio
  set sun-intensity 50                 ; intensidade inicial do sol
  set rain-intensity 50                ; intensidade inicial da chuva
  set climate-duration 50              ; duracao do clima
  setup-sun                            ; criar o sol
  create-turtles population [          ; cria formigas com base no valor do slider 'population
    ifelse random 100 < 75 [           ; 75% operarios e 25% guerreiras
      set ant-type "operaria"          ; operaria
      set size 1                       ; tamanho
      set color red                    ; cor
      set shape "ant"                  ; formato da formiga
      set life 3                       ; vida da formiga operaria
    ] [
      set ant-type "guerreira"        ; guerreira
      set size 2                      ; tamanho
      set color orange                ; cor
      set shape "ant 2"               ; formato
      set life 7                      ; vida
    ]
    set carrying-food? false          ; carregando comida falso
    set predator-alert false          ; alerta de predador falso
    set age 0                         ; inicaliza a idade das formigas como 0
  ]
  create-predators                    ; chama procedimento para criar predadores
  setup-patches                         ; chama o procedimento para configurar os patches
  reset-ticks                           ; reinicia o contador de tempo da simulação
end

to create-predators
  create-turtles 1                      ; Cria um predador
  [set size 11                          ; tamanho
   set color brown                      ; cor
   set label "tamandua"                 ; nome do predador
   set shape "bug"                      ; formato
   setxy -1 21                          ; posição do predador
   set life 60                         ; vida inicial predador(Tamanduá)
  ]
  ;;Cria o Sapo
  create-turtles 1                      ; Cria um predador
  [set size  4                          ; tamanho
   set color green                      ;cor
   set shape "frog top"                 ;nome do predador
   setxy 20 -22                         ;posição do predador
   set life 12                          ;vida inicial predador(Sapo)
  ]
  ; Cria a aranha
  create-turtles 1                     ; Cria um predador
  [set size 5                          ; tamanho
   set color magenta                       ; cor
   set shape "spider"                  ; formato
   setxy -20 0                         ; posição do predador
   set life 10                         ; vida inicial(aranha)
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
  if (distancexy (0.6 * max-pxcor) 0) < 5 [ ; Verifica se a distância do patch ao ponto (0.6 * max-pxcor, 0) é menor que 5. Este ponto está deslocado 60% para a direita no eixo X do ambiente.
    set food-source-number 1                ; Define food-source-number como 1, identificando que o patch faz parte da primeira fonte de alimento.
    set food 3                           ; Alta quantidade de comida
    set food-value 3                     ; alta nutrição
  ]
  if (distancexy (-0.6 * max-pxcor) (-0.6 * max-pycor)) < 5 [ ;Verifica se a distância do patch ao ponto (-0.6 * max-pxcor, -0.6 * max-pycor) é menor que 5. Este ponto está deslocado 60% para a esquerda no eixo X e 60% para baixo no eixo Y.
    set food-source-number 2               ; Define food-source-number como 2, identificando que o patch faz parte da segunda fonte de alimento.
    set food 2;                            ; Média quantidade de comida
    set food-value 2                       ; Nutrição Média
  ]
  if (distancexy (-0.8 * max-pxcor) (0.8 * max-pycor)) < 5 [ ; Verifica se a distância do patch ao ponto (-0.8 * max-pxcor, 0.8 * max-pycor) é menor que 5. Este ponto está deslocado 80% para a esquerda no eixo X e 80% para cima no eixo Y.
    set food-source-number 3              ; Define food-source-number como 3, identificando que o patch faz parte da terceira fonte de alimento.
    set food 1                            ; Baixa quantidade de comida
    set food-value 1                      ; Nutrição Baixa
  ]
  ; Se o patch faz parte de uma fonte de alimento, atribui uma quantidade de comida (1 ou 2)
  if food-source-number > 0 [ ;Verifica se o patch faz parte de uma fonte de alimento (food-source-number > 0).
    set food one-of [1 2 3] ; Define a quantidade de comida (food) como 1 2 ou 3, escolhida aleatoriamente.
  ]
end

to recolor-patch ; Altera a cor dos patches no ambiente do modelo em NetLogo com base em suas características ou estados,
  ifelse predator-pheromone > 0 [ ; Se o patch possui feromônio do predador (predator-pheromone > 0), sua cor será definida
    set pcolor scale-color yellow predator-pheromone 0.1 5 ; Feromônio do predador em amarelo
  ] [
    ifelse food > 0 [ ; Patches com comida são coloridos de acordo com a fonte
      if food-source-number = 1 [ set pcolor cyan ] ; Fonte 1: cyan (ciano).
      if food-source-number = 2 [ set pcolor sky ] ; Fonte 2: sky (azul claro).
      if food-source-number = 3 [ set pcolor lime ] ; Fonte 3: lime (lima).
    ] [
      ifelse nest? [ ;Se o patch é parte do ninho
         set pcolor violet ; Patches do ninho em violeta
       ] [
         ifelse chemical > 0 [ ; Se o patch possui feromônio químico (chemical > 0), sua cor será definida.
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
  toggle-rain          ; chuva alternada
  create-rain          ; cria a chuva
  move-rain            ; move a chuva
  evaporate-rain       ; evapora a chuva
  if raining? [        ; se estiver chovendo
    ask turtles with [ant-type = "operaria"] [ ; se for operaria
      fd 0.9  ; As operárias se movem mais devagar na chuva
    ]
  ]
  if raining? [        ; se estiver chovendo
    ask turtles with [ant-type = "guerreira"] [ ; se for guerreira
      fd 0.3  ; As guerreiras se movem mais devagar na chuva
    ]
  ]
  if sunny? [        ; se estiver fazendo sol
    ask patches [
      set chemical chemical * 0.8  ; Evaporação mais rápida de feromônios no sol
    ]
  ]
  ask turtles with [ant-type = "operaria"] [  ; se for operaria
    ifelse color = red [                      ; se a cor for vermelha
      look-for-food                            ; procura pela comida
    ] [
      return-to-nest                           ; se não for retorna pro ninho
    ]
    wiggle
 ; O procedimento wiggle adiciona uma variação aleatória no movimento da formiga.
    fd 2.5
 ; Move a formiga 2.5 unidades à frente, continuando sua busca ou retorno após ajustar sua direção com wiggle.
  ]
  ask turtles with [ant-type = "guerreira"] [ ; se for guerreira
  if predator-alert [                         ; se alerta de predador for verdadeiro
      defend-nest                            ; defendem o ninho
    ]
    patrol                                   ; patrulha
    fd 1                                     ; velocidade
    ]
  ; Lógica de mortalidade baseada na idade
  ask turtles [
    if ant-type = "operaria" [ ; Se for operaria
      set max-ant-age 60 + random 10 ; Operárias podem viver um pouco mais de 60 anos e variando ate 70
    ]
    if ant-type = "guerreira" [ ; Se for guerreira
      set max-ant-age 45 + random 5 ; Guerreiras têm vida mais curta devido ao esforço físico de 45 variando até 50
    ]
    if age >= max-ant-age [ die ] ; Remove formigas que atingiram a idade máxima
  ]
   let current-population count turtles with [ant-type = "operaria" or ant-type = "guerreira"] ; Conta o número total de formigas operárias e guerreiras presentes na simulação e armazena esse valor na variável current-population.

  ; Atualizar o gráfico
  set-current-plot "Reprodução de Formigas" ;Define o gráfico atual como "Reprodução de Formigas"
  set-current-plot-pen "Total de Formigas" ; "Total de Formigas".
  plot current-population  ; Plota o número total de formigas

  set-current-plot-pen "Nascimentos" ; Muda o pênsil para "Nascimentos"
  plot births-per-tick  ; Plota o número de nascimentos no tick atual

  set births-per-tick 0 ; ; Resetar a contagem de nascimentos para o próximo tick
    ask turtles with [ant-type != "sun"] [ ; verifica as formigas que são diferentes de sun
      if who >= ticks [ stop ]             ; sincroniza a saída das formigas do ninho com o tempo
  ]
   ask turtles [
    if ant-type = "operaria" or ant-type = "guerreira" [ ; se for operaria ou guerreira
      set age age + 1  ; Incrementa a idade a cada tick
      if age >= max-ant-age [ die ]  ; Remove a formiga se atingir a idade máxima
    ]
  ]
  pheromone-diffusion ; Difusão e evaporação dos feromônios
  recolor-patches     ; Atualiza a cor dos patches com base nos estados
  predator-move       ; Movimenta os predadores
  predator-attack    ; Predadores atacam formigas
  ant-defense        ; Formigas defendem-se e avisam outra
  tick               ; avança o contador de tempo da simulação
end

; === COMPORTAMENTOS DAS FORMIGAS ===

to look-for-food  ; procura por comida
  if food > 0 [                           ; Verifica se há comida

    if random 100 < (food-value * 33) [   ; 33% para cada ponto de valor nutricional/ 1 = 33% e 3 = 99%
      set carrying-food? true             ; a formiga pega o alimento
      set color yellow + 1                ; muda a cor para amarelo para indicar que está carregando comida
      set food food - 1                   ; reduz a quantidade de comida no patch
      set total-food-collected total-food-collected + 1         ; atualiza a quantidade de comida coletada
      rt 180                              ; vira 180 graus para retornar ao ninho
      stop                                ; finaliza o procedimento atual
    ]
  ]
  if (chemical >= 0.05) and (chemical < 2) [ ; Verifica se o nível de feromônio no patch atual está entre 0.05 e 2.
    uphill-chemical                     ; Chama o procedimento uphill-chemical, que direciona a formiga para seguir o gradiente de feromônio em busca de comida.
  ]
end

to patrol ; patrulhar a área
  if random 100 < 10 [ rt random 360 ]
;Movimento aleatório ocasional(probabilidade de 10%)/Se a condição for satisfeita, a tartaruga gira para a direita (rt)
;por um ângulo aleatório entre 0 e 359 graus (random 360).
end


to return-to-nest  ; retornar pro ninho
  ifelse nest? [   ; Comportamento dentro do ninho
    set color red                       ; deposita a comida e muda a cor para não carregando
      if not carrying-food? and random 100 < 80 [  ; A formiga não deve estar carregando comida e tem 80% de chance de reprodução
      hatch 3 [                         ; A formiga gera 3 novas tartarugas no patch atual (hatch 3), cada uma representando uma nova formiga.
        ifelse random 100 < 75 [        ; 75% de chance de nascer operária e 25% guerreira
          set ant-type "operaria"       ; tipo de formiga
          set life 3                    ; vida
          set size 1                    ; tamanho
          set color red                 ; cor
        ] [
          set ant-type "guerreira"      ; tipo de formiga
          set life 7                    ; vida
          set size 2                    ; tamanho
          set color orange              ; cor
        ]
        set age 0                       ; Nova formiga começa com idade 0
        set carrying-food? false        ; Não está carregando comida
        set predator-alert false        ; Sem alerta de predador
      ]
       set births-per-tick births-per-tick + 1  ; Incrementa a contagem de nascimentos
    ]
    rt 180                              ; vira 180 graus para sair novamente
  ] [
    set chemical chemical + 60          ; deposita feromônio no caminho de volta
    uphill-nest-scent                   ; move-se em direção ao ninho seguindo o gradiente
  ]
end

to defend-nest ; defesa do ninho
  let predator one-of turtles in-radius 2 with [label = "tamandua" or shape = "frog top" or shape = "spider"]
  ; se tiver um tamandua ou sapo ou aranha em um raio de 2
  if predator != nobody [                ; se predador for diferente d eninguem
    ask predator [
      set life life - 2 ; diminuem a vida -3 em -3
      if life <= 0 [ die ]  ; verifica a morte do predador
    ]
  ]
end


to ant-defense                           ;defesa/ataque das formigas
  ask turtles with [ant-type = "guerreira"] [        ; verifica se a formiga é guerreira
    let predator one-of turtles in-radius 3 with [label = "tamandua" or shape = "frog top" or shape = "spider"]
    ; verifica se o predador esta no raio 3
    if predator != nobody [                          ; se tiver preador
      ask predator [
        set life life - 2                ;diminui a vida de -1 em -1
        if life <= 0 [die]              ;verifica a morte ou nao do predaor
      ]
      set predator-alert true           ;alerta de predador
    ]
  ]
  ask turtles with [ant-type = "operaria"] [       ;verifica se a formiga é operaria
    let predator one-of turtles in-radius 1 with [label = "tamandua" or shape = "frog top" or shape = "spider"]
    ; verifica se o predador esta no raio 1
    if predator != nobody [                        ; se tiver predador
      ask predator [
        set life life - 0.5                          ; diminui a vida em -1 em -1
        if life <= 0 [die]                         ; verifica a morte do predador
      ]
      set predator-alert true                      ; alerta de predador
    ]
  ]
end

; === COMPORTAMENTO DOS PREDADORES ===

to predator-attack                       ;ataque do predador
  ask turtles with [label = "tamandua"] [ ; Verifica se e tamandua
    let prey one-of turtles in-radius 1 with [color = red or color = orange] ; verifica se há uma formiga no raio 1
    if prey != nobody [     ; se for diferente de ninguem
     ask prey [
       set life life - 7                  ;diminui a sua vida em -7
        if life <= 0 [die]                ;verifica a morte ou nao da formiga
      ]
     set predator-alert true             ;alerta do predador
    ]
  ]
   ask turtles with [shape = "frog top"] [ ; Verifica se e sapo
    let prey one-of turtles in-radius 1 with [color = red or color = orange] ; verifica se há uma formiga no raio 1
    if prey != nobody [     ; se for diferente de ninguem
     ask prey [
       set life life - 4                  ;diminui a sua vida em -4
        if life <= 0 [die]                ;verifica a morte ou nao da formiga
      ]
     set predator-alert true             ;alerta do predador
    ]
  ]
   ask turtles with [shape = "spider"] [ ; Verifica se e aranha
    let prey one-of turtles in-radius 1 with [color = red or color = orange] ; verifica se há uma formiga no raio 1
    if prey != nobody [     ; se for diferente de ninguem
     ask prey [
       set life life - 3                  ;diminui a sua vida em -3
        if life <= 0 [die]                ;verifica a morte ou nao da formiga
      ]
     set predator-alert true             ;alerta do predador
    ]
  ]
end

to predator-move
  ask turtles with [label = "tamandua"] [ ; se for tamandua
    let prey one-of turtles with [ant-type = "operaria" or ant-type = "guerreira"]
    ;; Define prey como uma tartaruga aleatória do conjunto de tartarugas com o tipo de formiga "operaria" ou "guerreira"
    ifelse prey != nobody [             ; Se prey não for nobody (há uma presa):
      face prey                         ; Predador olha na direção da presa
      fd 0.5                              ; Move-se em direção à presa
    ] [                                 ; se nao tiver presa
      rt random 4                      ; Caso não haja presa, move-se aleatoriamente de 0 a 3 graus para a direita
      lt random 4                      ; Gira um ângulo aleatório de 0 a 3 graus para a esquerda
      fd 0.2                           ; Move-se uma pequena distância
    ]
    if not can-move? 1 [ rt 180 ]       ; Se não puder se mover, gira 180 graus
  ]
  ask turtles with [shape = "frog top"] [ ; se for sapo
    let prey one-of turtles with [ant-type = "operaria" or ant-type = "guerreira"]
    ;  Define prey como uma tartaruga aleatória do conjunto de tartarugas com o tipo de formiga "operaria" ou "guerreira"
    ifelse prey != nobody [              ; Se prey não for nobody (há uma presa):
      face prey                         ; Predador olha na direção da presa
      fd 3                              ; Move-se em direção à presa
    ] [                                 ; se não tiver presa
      rt random 10                     ; Caso não haja presa, move-se aleatoriamente de 0 a 10 graus para a direita
      lt random 10                     ;  Gira um ângulo aleatório de 0 a 10 graus para a esquerda
      fd 1.2                           ; ; Move-se uma pequena distância
    ]
    if not can-move? 1 [ rt 180 ]       ; Se não puder se mover, gira 180 graus
  ]
   ask turtles with [shape = "spider"] [ ; se for aranha
    let prey one-of turtles with [ant-type = "operaria" or ant-type = "guerreira"]
    ;  Define prey como uma tartaruga aleatória do conjunto de tartarugas com o tipo de formiga "operaria" ou "guerreira"
    ifelse prey != nobody [              ; Se prey não for nobody (há uma presa):
      face prey                         ; Predador olha na direção da presa
      fd 2                              ; Move-se em direção à presa
    ] [                                 ; se não tiver presa
      rt random 7                     ; Caso não haja presa, move-se aleatoriamente de 0 a 10 graus para a direita
      lt random 7                     ;  Gira um ângulo aleatório de 0 a 10 graus para a esquerda
      fd 0.8                           ; ; Move-se uma pequena distância
    ]
    if not can-move? 1 [ rt 180 ]       ; Se não puder se mover, gira 180 graus
  ]

end



; === MOVIMENTAÇÃO E ORIENTAÇÃO ===

to uphill-chemical  ; procedimento das formigas
  let scent-ahead chemical-scent-at-angle 0 ; Intensidade detectada diretamente à frente da formiga (ângulo 0 graus).
  let scent-right chemical-scent-at-angle 45 ; Intensidade detectada a 45 graus à direita.
  let scent-left chemical-scent-at-angle -45 ; Intensidade detectada a 45 graus à esquerda.
  if (scent-right > scent-ahead) or (scent-left > scent-ahead) [ ; Verifica se há uma concentração maior de feromônio à direita ou à esquerda em comparação com a direção à frente
    ifelse scent-right > scent-left [ ; Se o feromônio à direita (scent-right) for mais intenso que o da esquerda (scent-left)
      rt 45                              ; vira 45 graus à direita
    ] [                                  ; caso nãos seja
      lt 45                              ; vira 45 graus à esquerda
    ]
  ]
end

to uphill-nest-scent  ; procedimento das formigas
  let scent-ahead nest-scent-at-angle 0 ;  Feromônio detectado diretamente à frente (ângulo 0 graus).
  let scent-right nest-scent-at-angle 45 ;  Feromônio detectado 45 graus à direita.
  let scent-left nest-scent-at-angle -45 ; Feromônio detectado 45 graus à esquerda.
  if (scent-right > scent-ahead) or (scent-left > scent-ahead) [ ; Verifica se o feromônio detectado à direita ou à esquerda é maior do que o detectado diretamente à frente:
    ifelse scent-right > scent-left [ ; Se o feromônio à direita (scent-right) for mais forte que o à esquerda (scent-left).
      rt 45                              ; vira 45 graus à direita
    ] [                                   ; caso não seja
      lt 45                              ; vira 45 graus à esquerda
    ]
  ]
end

to pheromone-diffusion; gerencia o chemical e predator-pheromone.
    diffuse chemical (diffusion-rate / 100) ; diffuse espalha o valor da variável chemical para os patches vizinhos./
    diffuse predator-pheromone 0.1          ; espalha o valor da variável predator-pheromone para patches vizinhos.
    ask patches [                           ;
      set chemical chemical * (100 - evaporation-rate) / 100 ; reduz o valor de chemical em cada patch / Multiplica o valor atual de chemical pelo fator (100 - evaporation-rate) / 100.
      set predator-pheromone predator-pheromone * 0.9        ; Isso simula a evaporação constante dos feromônios dos predadores.
  ]
end

to recolor-patches                       ; atualiza visivelmente o estado dos patches
  ask patches [                          ; executar os taches com base no que foi definido
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
   if raining? and not sunny? [         ; se etiver chovendo e não fazendo sol
    create-turtles rain-intensity [     ;cria intensidade da chiva
      set size 0.3                      ; tamanho
      set shape "raindrop"              ; gota importada da biblioteca e renomeada
      set color blue                    ; cor
      setxy random-xcor max-pycor       ; chuva caindo no mapa
      set heading 100                   ; de onde cai
    ]
  ]
end

to move-rain                           ;  movimentando a chuva
  ask turtles with [shape = "raindrop"] [ ; selecion a gota de chuva
    fd 3                                 ; aplica a velocidade
    if ycor <= min-pycor [               ; verifica se a posycor da chuva é menor ou igual a posy min do mundo(indica se a gota caiu)
      ask patch-here [                   ; identifca o patch na posição atual
        if pcolor != blue [set pcolor blue]    ; se a cor for diferente de azul, transforma em azul
      ]
      die                                ; remove a gota ao atingir o solo
    ]
  ]
end

to evaporate-rain                    ; desaparecendo com as gotas
  ask patches with [pcolor = blue] [ ; aplica as alterações com os patches cujo pclor são azuis
    set pcolor scale-color black random 10 0 10      ; transformando o azul em preto
  ]
end

to toggle-rain                 ; chance de chover
  if random 100 < 40 [         ; 20% de chance de mudar o estado a cada tick
    set raining? not raining?  ; Alterna entre true e false
  ]
end

to setup-sun                  ; criando o sol
  create-turtles 1 [
    set size 5                ; tamanho
    set color yellow          ; cor
    set shape "sun"           ; formato
    setxy 23 23               ; posição
  ]
end

to switch-climate              ; Mudança de clima
  if climate-duration = 0 [    ; verifica se a duracao do clima atingiu sua duração máxim
     ; Alterna entre sol e chuva
    ifelse sunny? [            ; se sunny for verdadeiro
      set sunny? false         ; se torna falso o sol
      set raining? true        ; se torna verdadeiro a chuva
    ] [
      set sunny? true          ; torna verdadeiro o sol
      set raining? false       ; a chuva se torna falso
    ]

    set climate-duration random 50 + 50  ; Define nova duração entre 50 e 100 ticks

    ; Ajusta intensidade do sol ou zera durante chuva
    ifelse sunny? [                      ; se sunny for verdadeiro
      set sun-intensity random 50 + 50   ; ajusta a intensidade do sol
    ] [
      set sun-intensity 0               ; se sunny for falso, a intesidade do sol é 0
    ]

    ; Ajusta a cor do sol com base no clima
    ask turtles with [shape = "sun"] [
      ifelse sunny? [                  ; se sunny for verdadeiro
        set color yellow  ; Sol fica amarelo
      ] [
        set color gray    ; Sol fica cinza
      ]
    ]
  ]

  ; Reduz o contador de duração
  set climate-duration climate-duration - 1 ; Reduz climate-duration em 1 a cada tick, representando o passar do tempo.
end



to sunny-effects                                  ; efeitos do sol
  if sunny? [                                     ; se sunny for verdadeiro
    ask patches with [pcolor = blue] [            ; seleciona o patch de cor azul
      set pcolor scale-color black (sun-intensity / 10) 0 10 ; Evaporação proporcional à intensidade do sol/transforma em preto para ilustrar a evaporacao
    ]
  ]
end

to adjust-sun-visuals                          ; ajustes do efeio do sol
  ask turtles with [label = "☀"] [             ; seleciona o sol
    set size (sun-intensity / 20) + 2           ; Tamanho proporcional à intensidade
    ifelse sunny? [                             ; verifica se sunnny e true
      set color yellow                          ; fica amarelo se for true
    ] [
      set color gray                            ; fica cinza se for false
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
10
38
182
71
population
population
600
1000
600.0
1
1
NIL
HORIZONTAL

SLIDER
9
114
181
147
diffusion-rate
diffusion-rate
50
100
51.0
1
1
NIL
HORIZONTAL

SLIDER
11
198
183
231
evaporation-rate
evaporation-rate
10
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
1057
36
1120
69
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
920
33
983
66
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

PLOT
913
190
1113
340
Reprodução de Formigas
Ticks
Número de Formigas
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Total de Formigas" 1.0 0 -8053223 true "" "set-current-plot-pen \"Total de Formigas\"\n  plot current-population"
"Nascimentos" 1.0 0 -12087248 true "" " set-current-plot-pen \"Nascimentos\"\n  plot births-per-tick  "

PLOT
1191
195
1391
345
Food Collection
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Food-Collected" 1.0 0 -16777216 true "" "plot total-food-collected"

PLOT
1024
432
1224
582
Food in each Pile
time
food
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

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

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

ant 2
true
0
Polygon -7500403 true true 150 19 120 30 120 45 130 66 144 81 127 96 129 113 144 134 136 185 121 195 114 217 120 255 135 270 165 270 180 255 188 218 181 195 165 184 157 134 170 115 173 95 156 81 171 66 181 42 180 30
Polygon -7500403 true true 150 167 159 185 190 182 225 212 255 257 240 212 200 170 154 172
Polygon -7500403 true true 161 167 201 150 237 149 281 182 245 140 202 137 158 154
Polygon -7500403 true true 155 135 185 120 230 105 275 75 233 115 201 124 155 150
Line -7500403 true 120 36 75 45
Line -7500403 true 75 45 90 15
Line -7500403 true 180 35 225 45
Line -7500403 true 225 45 210 15
Polygon -7500403 true true 145 135 115 120 70 105 25 75 67 115 99 124 145 150
Polygon -7500403 true true 139 167 99 150 63 149 19 182 55 140 98 137 142 154
Polygon -7500403 true true 150 167 141 185 110 182 75 212 45 257 60 212 100 170 146 172

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

frog top
true
0
Polygon -7500403 true true 146 18 135 30 119 42 105 90 90 150 105 195 135 225 165 225 195 195 210 150 195 90 180 41 165 30 155 18
Polygon -7500403 true true 91 176 67 148 70 121 66 119 61 133 59 111 53 111 52 131 47 115 42 120 46 146 55 187 80 237 106 269 116 268 114 214 131 222
Polygon -7500403 true true 185 62 234 84 223 51 226 48 234 61 235 38 240 38 243 60 252 46 255 49 244 95 188 92
Polygon -7500403 true true 115 62 66 84 77 51 74 48 66 61 65 38 60 38 57 60 48 46 45 49 56 95 112 92
Polygon -7500403 true true 200 186 233 148 230 121 234 119 239 133 241 111 247 111 248 131 253 115 258 120 254 146 245 187 220 237 194 269 184 268 186 214 169 222
Circle -16777216 true false 157 38 18
Circle -16777216 true false 125 38 18

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

raindrop
false
0
Circle -7500403 true true 73 133 152
Polygon -7500403 true true 219 181 205 152 185 120 174 95 163 64 156 37 149 7 147 166
Polygon -7500403 true true 79 182 95 152 115 120 126 95 137 64 144 37 150 6 154 165

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

spider
true
0
Polygon -7500403 true true 134 255 104 240 96 210 98 196 114 171 134 150 119 135 119 120 134 105 164 105 179 120 179 135 164 150 185 173 199 195 203 210 194 240 164 255
Line -7500403 true 167 109 170 90
Line -7500403 true 170 91 156 88
Line -7500403 true 130 91 144 88
Line -7500403 true 133 109 130 90
Polygon -7500403 true true 167 117 207 102 216 71 227 27 227 72 212 117 167 132
Polygon -7500403 true true 164 210 158 194 195 195 225 210 195 285 240 210 210 180 164 180
Polygon -7500403 true true 136 210 142 194 105 195 75 210 105 285 60 210 90 180 136 180
Polygon -7500403 true true 133 117 93 102 84 71 73 27 73 72 88 117 133 132
Polygon -7500403 true true 163 140 214 129 234 114 255 74 242 126 216 143 164 152
Polygon -7500403 true true 161 183 203 167 239 180 268 239 249 171 202 153 163 162
Polygon -7500403 true true 137 140 86 129 66 114 45 74 58 126 84 143 136 152
Polygon -7500403 true true 139 183 97 167 61 180 32 239 51 171 98 153 137 162

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

sun
false
0
Circle -7500403 true true 75 75 150
Polygon -7500403 true true 300 150 240 120 240 180
Polygon -7500403 true true 150 0 120 60 180 60
Polygon -7500403 true true 150 300 120 240 180 240
Polygon -7500403 true true 0 150 60 120 60 180
Polygon -7500403 true true 60 195 105 240 45 255
Polygon -7500403 true true 60 105 105 60 45 45
Polygon -7500403 true true 195 60 240 105 255 45
Polygon -7500403 true true 240 195 195 240 255 255

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
