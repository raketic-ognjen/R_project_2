---
title: "Project 2 in R"
author: "Ognjen Raketic"
date: "2023-08-16"
output: html_document
---

-   The European Banking Authority EBA conducts a biannual stress testing exercise for the biggest European banks every two years. In the stress test bank exposure data are collected and then particular stress scenarios are applied to the reported data. The goal is to find out whether the banks would have enough capital to withstand an adverse scenario. EBA makes a huge effort to publish the data that are the base of the stress test on its web site: <https://www.eba.europa.eu/risk-analysis-and-data/eu-wide-stress-testing>

-   In this project you are asked to use the knowledge you learned about empirical probabilities, R and Benford's law to check whether the EBA stress testing data show the distribution of leading digits, you would expect from Benford's law.

-   Go to the EBA website <https://www.eba.europa.eu/risk-analysis-and-data/eu-wide-stress-testing> and download the file Credit Risk IRB (<https://www.eba.europa.eu/assets/st21/full_database/TRA_CRE_IRB.csv>). You can do so by downloading the file, storing it locally and then read it into R or you can read it directly from the web.

-   We want to study the distribution of leading digits in the Amounts reported in the EBA file of credit risk exposures. Now the csv file contains many different data that all somehow belong to the EBA stress test. We would not like to check all data but only exposure data. We need first to filter the data to make sure we have a meaningful collection of exposure data for all the banks. The description of the data and the data dimensions is in the files Metadata_TR.xlsx and Data_Dictionary.xlsx. You are welcome to study these data in detail. It will probably need more time than you have available. They are also quite complicated. Since the aim of this project is not directly to understand the eba-data but to work with your R-concepts and probability concepts, let me guide you here how to filter these data in 10 sequential steps. Note that this sequencing is for didactical reasons only and for the purpose not to loose oversight. With routine and experience all these steps can be done in one go as well:

1.  Extract all variables names, using the names()function.

2.  Select all rows where the Scenario variable has value 1. Note that the symbol you need in the R syntax for equal is ==, the syntax is therefore Scenario == 1. You might check out the R-help entry Comparison for further details.

3.  From the resulting data-frame select all rows where the Country variable is not equal to 0. (hint: The not equal operator in the R syntax is !=). If you look into the Metadata-File you will see that 0 are all the aggregate exposures not broken down by country. Excluding these will give us country exposures.

4.  From the resulting data frame select all rows where the Portfolio variable has value 1 or 2.These codes describe the accounting rules under which the exposure values are reported, internal rating based (IRB) or standard approach (SA). As a hint you can use R's subset operator %in% here so Portfolio %in% c(1,2) written with the approprate subsetting rule will select all rows where the Porfolio variable has value 1 or 2.

5.  From the resulting data frame choose all the rows where the Exposure variable is not 0.This gives again disaggregated numbers.

6.  From the resulting data frame choose all the rows where the Status variable has value 0.

7.  From the resulting data frame choose all the rows where the IFRS9_Stages variable has value 1,2, or 3.

8.  From the resulting data frame choose all the rows where the CR_guarantees variable is 0

9.  From the resulting data frame choose all the rows where the CR_exp_moratoria variable is 0.

10. From the resulting data frame, drop all rows where the Amount variable is 0.

-   We start with importing data:

```{r}
eba_data <- read.csv("https://www.eba.europa.eu/assets/st21/full_database/TRA_CRE_IRB.csv")
```

-   This should result in an R-object eba_data (or whatever name you chose to give to the data) with 528550 records of 15 variables. One way to check this would be the dim() function we also used in the lecture:

```{r}
dim(eba_data)
```

-   2.(a) We refer to our data object by name eba_data. You must choose the name you have selected, of course.

```{r}
names(eba_data)
```

-   2.(b) Select all rows where the Scenario variable has value 1. Note that the symbol you need in the R syntax for equal is ==, the syntax is therefore Scenario == 1. You might check out the R-help entry Comparison for further details.

```{r}
eba_data <- eba_data[eba_data$Scenario == 1,]
```

-   Explanation: Since our object name is eba_data we subset it by eba_data$$, $$. The first slot addresses rows the second slot addresses columns. We want to say: Take those rows where the column Scenario takes value 1. The column scenario is eba_data\$Scenario. The filter condition is thus written in the row slot. The column slot is left blank because we want to have records for each variable. Note that without warning R has created here a new object, with the same name than the old one. But the new eba_data has only those rows left, where the Scenario-Variable is equal to 1.

-   2.(c) From the resulting data-frame select all rows where the Country variable is not equal to 0. (hint: The not equal operator in the R syntax is !=). If you look into the Metadata-File you will see that 0 are all the aggregate exposures not broken down by country. Excluding these will give us country exposures.

```{r}
eba_data <- eba_data[eba_data$Country_code!=0,]
```

-   2\. (d) From the resulting data frame select all rows where the Portfolio variable has value 1 or 2.These codes describe the accounting rules under which the exposure values are reported, internal rating based (IRB) or standard approach (SA). As a hint you can use R's subset operator %in% here so Portfolio %in% c(1,2) written with the approprate subsetting rule will select all rows where the Porfolio variable has value 1 or 2.

```{r}
eba_data <- eba_data[eba_data$Portfolio %in% c(1,2),]
```

-   $e$ From the resulting data frame choose all the rows where the Exposure variable is not 0.This gives again disaggregated numbers.

```{r}
eba_data <- eba_data[eba_data$Exposure != 0,]
```

-   2.(f) From the resulting data frame choose all the rows where the Status variable has value 0.

```{r}
eba_data <- eba_data[eba_data$Status == 0,]
```

-   2.(g) From the resulting data frame choose all the rows where the IFRS9_Stages variable has value 1,2, or 3.

```{r}
eba_data <- eba_data[eba_data$IFRS9_Stages %in% c(1,2,3),]
```

-   2.(h) From the resulting data frame choose all the rows where the CR_guarantees variable is 0

```{r}
eba_data <- eba_data[eba_data$CR_guarantees == 0, ]
```

-   2.(i)From the resulting data frame choose all the rows where the CR_exp_moratoria variable is 0.

```{r}
eba_data <- eba_data[eba_data$CR_exp_moratoria == 0, ]
```

-   2.(j) From the resulting data frame, drop all rows where the Amount variable is 0.

```{r}
eba_data <- eba_data[eba_data$Amount != 0, ]
```

-   This results in a new data frame with dimension:

```{r}
dim(eba_data)
```

-   <div>

    3.  Check the type of the Amount variable.

    </div>

```{r}
typeof(eba_data$Amount)
```

-   Explanation: `typeof(eba_data$Amount)` checks the type of the variable and returns the actual type. We have reported amounts as strings of characters not as numerics in the data so far

-   <div>

    4.  Transform the Amount variable to type \`numeric()\`

    </div>

    ```{r}
    eba_data$Amount <- as.numeric(eba_data$Amount)
    ```

-   <div>

    5.  Check for NA in the Amount variable in the resulting data frame and if you find any, remove them.

    </div>

    ```{r}
    sum(is.na(eba_data$Amount))
    ```

-   Explanation: `is.na(eba_data$Amount)` returns a logical vector which is `TRUE` at the components where the Amount variable has value `NA`and `FALSE`otherwise. Applying `sum()` to this vector coerces `TRUE`to 1 and `FALSE`to 0. If 0 there is no `NA` otherwise we have some, in particular we have 5763 instances of `NA`. This comes from the fact that some components in Amount contained the character `.` which returns `NA`if `as.numeric()`is applied to it. This seems clear, since after all `.` is a string which corresponds to no number.

    ```{r}
    eba_data<-na.omit(eba_data)
    ```

-   <div>

    6.  Change the Amount variable from the actual unit of Million Euros to the unit of 1 Euro and throw away data smaller than 1 after this transformation.

    </div>

```{r}
eba_data$Amount <- eba_data$Amount*10^6
```

-   Explanation: If an amount is expressed in units of one million, one million Euro appears as 1. If we multiply by 10\^6 this is expressed as 1 000 000. We transform the Amount variable in this way and overwrite the old variable by the values with the new units

    ```{r}
    eba_data <- eba_data[eba_data$Amount >= 1, ]
    ```

-   Explanation: We identify the values larger than 1 by logical subsetting of the Amount variable and select all these values from the data frame by selecting all rows where the Amount variable is larger than 1.

-   <div>

    7.  Select the leading digits from the Amount variable, using R's string functions and add a variable with name LD to your data frame.

    </div>

```{r}
eba_data$LD <- as.character(eba_data$Amount) |> substr(1,1)
```

-   Explanation: We can extract the leading digit from a string of characters `x` by applying the `substr()` function, with arguments `1,1` to `x`. To operate with this logic on Amount, we have to transform the type of Amount back to character first. We then use the R-pipe to apply substr to this new variables. The syntax is equivalent to `substr(as.character(eba_data$Amount),1,1)`

-   <div>

    8.  Compare the empirical frequencies in the data with the theoretical frequencies from Benford's law. Do the data look ok or suspicious?

    </div>

```{r}
comptable <- as.data.frame(table(eba_data$LD)/length(eba_data$LD))
names(comptable) <- c("Digit","Freq")
```

-   Explanation: We tabulate the LD data using the R function `table()`. We divide each count by the number of observations using the `length()`function to get proportions. The output of this operation is then forced into a data frame and saved in the variable `comptable` we assign the names `Digit`and `Freq` to the variables.

    ```{r}
    comptable$Freq_Benf <- log10(1+1/as.numeric(comptable$Digit))
    ```

-   Explanation: We add a new variable to our data frame using the formula for Benfords law for the distribution of digits \$\${1,2,3,4,5,6,7,8,9}\$\$. Since we do a computation with logs and division we have to be careful to change the type of our character numbers which are expressed as strings to numerical types first.

    ```{r}
    comptable
    ```

-   The digit distribution matches up very well. So from the perspective of Benford's law about the distribution of leading digits the EBA exposure data from the one data file we inspected here look perfectly ok and seem not to be cooked up in any way. Note that this does not mean that there are no problems in these data. This analysis just provides some first order evidence that the data seem not to be obviously manipulated or forged.
