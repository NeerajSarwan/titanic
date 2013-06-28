library("randomForest")

formatData = function(fileName)
{
	input = read.csv(fileName, stringsAsFactors = F)

    # change empty strings to NA
    input$ticket  [which(input$ticket   == "")] = NA
    input$cabin   [which(input$cabin    == "")] = NA
    input$embarked[which(input$embarked == "")] = NA

    # change categorical columns to factors
    # test data don't have "survived"
    if ("survived" %in% names(input))
    {
        input$survived = factor(input$survived)
    }
    input$pclass   = factor(input$pclass)
    input$sex      = factor(input$sex)
    input$embarked = factor(input$embarked)

    # drop unnecessary columns
    input$name   = NULL
    input$ticket = NULL
    input$cabin  = NULL

	return(input)
}

trainRF = function(X, d, n = 200)
{
    # Xfill = rfImpute(X, y, ntree = n, mtry = d)
    # Xfill$y = NULL
    RF = randomForest(X$survived ~ ., X, ntree = n, mtry = d, na.action = na.omit)
    CM = RF$confusion[, 1:2]
    err = 1 - sum(diag(CM)) / sum(CM)
}

# fill test missing values by regression
fill = function(X, test, column)
{
	regRF = randomForest(X[, column] ~ ., X, na.action = na.omit)
	na.i = which(is.na(test[column]))
	rows = test[na.i, ]
	rows[column] = NULL
	test[na.i, column] = predict(regRF, rows)
}

train = formatData("train.csv")
test = formatData("test.csv")

# X = rfImpute(train$survived ~ ., train)[, 2:ncol(train)] # fill missing values

# missRF = randomForest(train$survived ~ ., train, ntree = 100, mtry = 3, na.action = na.omit)
# fillRF = randomForest(X, train$survived, ntree = 100, mtry = 3)

# convergence curve
# X1 = Xfill[1:594, ]
# y1 = y[1:594]
# X2 = Xfill[595:891, ]
# y2 = y[595:891]
# forest = randomForest(X1, y1, X2, y2, ntree = 8000)
# plot($err.rate[, 'OOB'])

# validation curve
# plot(sapply(1:ncol(X), function(d) { trainRF(train, d) }), type = 'l')

# fill missing test values
# Xage = Xfill
# Xage$age = NULL
# ageRF = randomForest(Xage, Xfill$age)

# fill missing test values by rfImpute
# X0 = na.roughfix(test)
# y0 = predict(forest, X0)

# while (T)
# {
	# X1 = rfImpute(test, y0, iter = 1)
	# y1 = predict(forest, X1)

	# if (sum(y1 != y0) == 0) break

	# y0 = y1
# }

# p1 = predict(missRF, X0)
# p2 = predict(fillRF, X0)

# write(as.vector(p1), "prediction1.csv", 1)
# write(as.vector(p2), "prediction2.csv", 1)