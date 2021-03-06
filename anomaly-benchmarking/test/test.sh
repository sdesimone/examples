#!/bin/bash

source ../../test-utils.sh

rm -f -R cmd_del
rm -f -R cmd
rm -f -R .build

log "-------------------------------------------------------"
log "Test for make-binary script"
run_bigmler whizzml --package-dir ../ --output-dir ./.build
# creating the resources needed to run the test
run_bigmler --train https://archive.ics.uci.edu/ml/machine-learning-databases/car/car.data --no-model \
            --project "Whizzml examples tests" --output-dir cmd/pre_test
run_bigmler --train https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data --no-model \
            --project "Whizzml examples tests" --output-dir cmd/pre_test
run_bigmler --train https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data --no-model \
            --project "Whizzml examples tests" --output-dir cmd/pre_test



# building the inputs for the test
prefix='[["dataset-id", "'
suffix='"]]'
text=''
cat cmd/pre_test/dataset | while read dataset
do
echo "$prefix$dataset$suffix" > "test_inputs.json"
done
log "Testing make-binary script -------------------------------"
# running the execution with the given inputs
run_bigmler execute --scripts .build/scripts --inputs test_inputs.json \
                    --output-dir cmd/results
# check the outputs
declare file="cmd/results/whizzml_results.json"
declare regex="\"outputs\": \[\[\"binary-dataset\", "
declare file_content=$( cat "${file}" )
if [[ " $file_content " =~ $regex ]]
    then
        log "multi-to-binary OK"
    else
        echo "multi-to-binary KO:\n $file_content"
        exit 1
fi
# remove the created resources
run_bigmler delete --from-dir cmd --output-dir cmd_del
run_bigmler delete --from-dir .build --output-dir cmd_del
rm -f -R test_inputs.json cmd cmd_del
rm -f -R .build .bigmler*
