#write table categorisation in latex:

table_categorisation <- read_csv("C:/Users/cogneuro/Desktop/HCS_analysis/table_categorisation.csv")


xtable::xtable(table_categorisation, label = "tab:category",
               caption ="The initial 45 categories were pooled into 18 and 10 categories.") ->a
print(a,include.rownames=F)
