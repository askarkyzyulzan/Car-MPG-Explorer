library(shiny)

cars <- mtcars
cars$am <- factor(cars$am, levels=c(0,1), labels=c('Automatic','Manual'))
fit <- lm(mpg ~ wt + hp + am, data=cars)

shinyServer(function(input,output,session) {
  candidate <- reactive({
    data.frame(wt=input$wt, hp=input$hp,
               am=factor(if(input$am=='1') 'Manual' else 'Automatic',
                         levels=levels(cars$am)))
  })
  predicted <- reactive({predict(fit,newdata=candidate(),interval='prediction',level=.95)})
  both <- reactive({
    d <- data.frame(wt=rep(input$wt,2),hp=rep(input$hp,2),
                    am=factor(c('Automatic','Manual'),levels=levels(cars$am)))
    data.frame(transmission=d$am, mpg=as.numeric(predict(fit,newdata=d)))
  })
  output$estimate <- renderText({sprintf('%.1f MPG',predicted()[1,'fit'])})
  output$interval <- renderText({
    sprintf('95%% prediction interval: %.1f to %.1f MPG',
            predicted()[1,'lwr'],predicted()[1,'upr'])
  })
  output$comparisonPlot <- renderPlot({
    b <- both()
    if(input$showPoints) {
      plot(jitter(as.numeric(cars$am),amount=.12),cars$mpg,
           xlim=c(.65,2.35),ylim=range(c(cars$mpg,b$mpg),finite=TRUE)+c(-3,3),
           xaxt='n',xlab='Transmission',ylab='Miles per gallon (MPG)',
           main='Observed cars and model predictions',pch=16,col='#aab8c8')
    } else {
      plot(NA,xlim=c(.65,2.35),ylim=range(c(cars$mpg,b$mpg),finite=TRUE)+c(-3,3),
           xaxt='n',xlab='Transmission',ylab='Miles per gallon (MPG)',
           main='Predicted MPG at selected weight and horsepower')
    }
    axis(1,at=1:2,labels=c('Automatic','Manual'))
    points(1:2,b$mpg,pch=19,cex=2,col=c('#db7143','#2679b7'))
    text(1:2,b$mpg+1.4,labels=sprintf('%.1f',b$mpg),col='#17243c',font=2)
    legend('topright',legend=c('Observed cars','Model estimates'),
           pch=c(16,19),col=c('#aab8c8','#2679b7'),bty='n',cex=.85)
  })
  output$modelInfo <- renderPrint({
    cat(sprintf('Training dataset: %d cars\n',nrow(cars)))
    cat(sprintf('Model adjusted R-squared: %.3f\n',summary(fit)$adj.r.squared))
    cat(sprintf('Estimated manual-vs-automatic difference at the same weight and horsepower: %+.2f MPG\n',
                unname(coef(fit)['amManual'])))
    cat('Prediction intervals reflect uncertainty for an individual car, under model assumptions.\n')
  })
})
