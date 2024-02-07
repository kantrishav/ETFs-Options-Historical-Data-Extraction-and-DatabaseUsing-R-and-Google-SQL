install.packages("readxl")
install.packages("jsonlite")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("shiny")
install.packages("stringr")
install.packages("RQuantLib")
install.packages("derivmkts")
install.packages("pbapply")



require("jsonlite");require("stringr");require("RQuantLib");require("derivmkts");require("pbapply")

# function to extract Expirations, Flag, and Strike from Option Name
getEFS = function(x)
{
  expiry = str_sub(x, -15,-10)
  expiry = as.character(as.Date(expiry,format="%y%m%d"))
  flag   = str_sub(x,-9,-9)
  strike = str_sub(x,-8,-1)
  left   = str_sub(strike,-8,-4)
  right  = str_sub(strike,-3,-1)  
  strike = paste0(left,".",right)
  strike = as.numeric(strike)
  as.data.frame(cbind(expiry,flag,strike))
}

# get Options + Calculate IV & Greeks
CBOE_Options = function(symbol,EXERCISE){
  # url to get options - will read in all using json
  #url = "https://cdn.cboe.com/api/global/delayed_quotes/options/_SPX.json"
  url = paste0("https://cdn.cboe.com/api/global/delayed_quotes/options/",symbol,".json")
  # read in data from page
  df = read_json(url,simplifyVector = TRUE)
  # convert as data frame
  opts = as.data.frame(df$data$options)
  # get Expiration, Flag, & Strike
  efs <- getEFS(opts$option)
  # combine with options data
  opts <- cbind(opts,efs)
  # fix last_trade_time
  opts$last_trade_time <- as.character(as.POSIXct(opts$last_trade_time,
                                                  format="%Y-%m-%dT%H:%M:%S"))
  opts$stkClose <- df$data$close
  # add date pulled
  opts$Date = as.character(Sys.Date())
  # add Days to Expiration
  opts$days2Exp = as.Date(opts$expiry) - as.Date(opts$Date)
  # Option Mid Price  
  opts$Mid = round((opts$bid + opts$ask)/2,2)
  
  # calculate IV
  if(EXERCISE == "european")
  {
    ivs = pblapply(as.list(1:nrow(opts)),function(ii){
      tmp = try(EuropeanOptionImpliedVolatility(
        type = ifelse(opts$flag[ii] == "C","call","put"),
        value=as.numeric(opts$Mid)[ii],
        underlying=as.numeric(df$data$close),
        strike=as.numeric(opts$strike)[ii],
        dividendYield=0,
        riskFreeRate=0,
        maturity=as.numeric(yearFraction(as.Date(opts$Date[ii]),
                                         as.Date(opts$expiry[ii]),
                                         1)),
        volatility=as.numeric(df$data$iv30/100)),
        silent=TRUE)
      if(inherits(tmp,'try-error')){
        iv = round(as.numeric(df$data$iv30/100),4)
      }else{
        iv = round(tmp[[1]],4)
      }
      iv
    })
    
  }else{
    ivs = pblapply(as.list(1:nrow(opts)),function(ii){
      tmp = try(AmericanOptionImpliedVolatility(
        type = ifelse(opts$flag[ii] == "C","call","put"),
        value=as.numeric(opts$Mid)[ii],
        underlying=as.numeric(df$data$close),
        strike=as.numeric(opts$strike)[ii],
        dividendYield=0,
        riskFreeRate=0,
        maturity=as.numeric(yearFraction(as.Date(opts$Date[ii]),
                                         as.Date(opts$expiry[ii]),
                                         1)),
        volatility=as.numeric(df$data$iv30/100)),
        silent=TRUE)
      if(inherits(tmp,'try-error')){
        iv = round(as.numeric(df$data$iv30/100),4)
      }else{
        iv = round(tmp[[1]],4)
      }
      iv
    })
  }
  
  # add Caluclated IVs to Options Date
  opts$calc_IV = do.call(rbind,ivs)  
  
  # calculate greeks
  CALLS = subset(opts, opts$flag == "C")
  PUTS = subset(opts, opts$flag == "P")
  
  # greeks for calls
  cGREEKS = greeks2(bscall,list(s=as.numeric(CALLS$stkClose),
                                k=as.numeric(CALLS$strike),
                                v=as.numeric(CALLS$calc_IV),
                                r=rep(0,nrow(CALLS)),
                                tt=as.numeric(CALLS$days2Exp)/252,
                                d=rep(0,nrow(CALLS))))  
  # transpose greeks
  cGREEKS = t(cGREEKS)
  # combine with call options
  CALLS = cbind(CALLS,cGREEKS)
  
  # greeks for calls
  pGREEKS = greeks2(bsput,list(s=as.numeric(PUTS$stkClose),
                               k=as.numeric(PUTS$strike),
                               v=as.numeric(PUTS$calc_IV),
                               r=rep(0,nrow(PUTS)),
                               tt=as.numeric(PUTS$days2Exp)/252,
                               d=rep(0,nrow(PUTS))))  
  # transpose greeks
  pGREEKS = t(pGREEKS)
  # combine with call options
  PUTS = cbind(PUTS,pGREEKS)
  # combine calls/puts
  opts = rbind(CALLS,PUTS)
  # add ticker column
  opts$Symbol = symbol
  opts
}



# get CBOE options
opts1 = CBOE_Options(symbol="_SPX",EXERCISE = "european")
opts2 = CBOE_Options(symbol="TSLA",EXERCISE = "american")
View(opts2)



etf_list = c( 'EPI' , 'SMH', 'RTH', '_NDX', '_RUT', 'DBA', 'XHB', 'ARKG', 'ARKF',
              'EWW', 'VNQ', 'HYG', 'XLP', 'XLU' ,'_SPX', 'XOP' ,'LQD', 'ARKK', 'XLF', 'SLV', 'EEM',
              'HYG', 'IWM', 'QQQ', 'FXI', 'XLE', 'KWEB', 'TLT', 'EWZ', 'EFA', 'GDX', 'DIA', 'GLD')


#opts = CBOE_Options(symbol="GLD",EXERCISE = "american")


length(etf_list)

i = 1
option_df = data.frame()
combined_option_df = data.frame()

while (i < length(etf_list) ) {
  
  print(etf_list[i])
  
  option_df = CBOE_Options(symbol= etf_list[i] ,EXERCISE =  "american")
  
  combined_option_df = rbind(option_df ,combined_option_df )
  
  
  i = i +1
}

data_opt <- combined_option_df[,c(1:28,40)]

dim(data_opt)



dbWriteTable(con, name = "OPTION_HISTORY", value = data_opt, append = TRUE)
dbWriteTable(con, name = "OPTION_HISTORY", value = data_opt, overwrite = TRUE)



dbWriteTable(con, name = "OPTION_HISTORY_BACKUP_STORE", value = data_opt, overwrite = TRUE)

dbGetQuery(con, "select COUNT(*) from OPTION_HISTORY_BACKUP_STORE")

dbGetQuery(con, "select DISTINCT Date from OPTION_HISTORY")
