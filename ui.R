library(shiny)

shinyUI(fluidPage(
  tags$head(tags$style(HTML('
    body {background:#f7f9fc; color:#17243c;}
    .well {background:white; border:1px solid #dee5f0; border-radius:12px;}
    .summary {background:#eaf3ff; padding:18px; border-radius:12px; margin:8px 0 18px;}
  '))),
  titlePanel('Car MPG Explorer | Interactive Fuel Economy Estimator'),
  p('Explore how vehicle weight, horsepower, and transmission relate to fuel economy using the built-in R mtcars dataset.'),
  sidebarLayout(
    sidebarPanel(
      h4('Choose a vehicle profile'),
      sliderInput('wt','Weight (1,000 lb)',min=1.5,max=5.5,value=3.0,step=0.1),
      sliderInput('hp','Horsepower',min=50,max=300,value=120,step=10),
      radioButtons('am','Transmission',choices=c('Automatic'='0','Manual'='1'),selected='1'),
      checkboxInput('showPoints','Show observed cars on chart',TRUE),
      helpText('Move the sliders or change the transmission. Results update automatically.')
    ),
    mainPanel(
      div(class='summary',h4('Estimated fuel economy'),h2(textOutput('estimate',inline=TRUE)),textOutput('interval')),
      plotOutput('comparisonPlot',height='340px'),
      h4('Model information'),
      verbatimTextOutput('modelInfo'),
      tags$hr(),
      h3('How to use this app'),
      tags$ol(
        tags$li('Choose the vehicle weight using the first slider.'),
        tags$li('Choose the horsepower using the second slider.'),
        tags$li('Select automatic or manual transmission.'),
        tags$li('Read the predicted MPG and 95% prediction interval above the chart.'),
        tags$li('Compare the two transmission predictions on the chart; check the box to display real cars.')
      ),
      p(strong('What is MPG? '),'Miles per gallon measures fuel economy: higher values mean less fuel used per mile.'),
      p(strong('How are estimates calculated? '),'A linear regression model is fitted on the 32 cars in mtcars: mpg ~ wt + hp + am. The blue and orange markers show model predictions at your chosen weight and horsepower.'),
      p(strong('Important limitation: '),'This is an educational association model, not a causal claim. The dataset is small and historical, and accuracy outside the observed range may be poor.'),
      p(strong('Data: '),'R built-in mtcars dataset (32 cars; Motor Trend 1974 road tests).')
    )
  )
))
