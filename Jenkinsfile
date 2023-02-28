node {
    stage('Clone repository') {
        checkout scm
    }

    stage('Download latest Prisma Cloud twistcli') {
        withCredentials([usernamePassword(credentialsId: 'prisma_cloud', passwordVariable: 'PC_PASS', usernameVariable: 'PC_USER')]) {
            sh 'curl -k -u $PC_USER:$PC_PASS --output ./twistcli https://$PC_CONSOLE/api/v1/util/twistcli'
            sh 'sudo chmod a+x ./twistcli'
        }
    }

    stage('Prisma Cloud Scan Lambda Function IaC') {
        sh('terraform -chdir=terraform init')
        sh('terraform -chdir=terraform plan -out=MYPLAN.bin')
        sh('terraform -chdir=terraform show -json MYPLAN.bin > MYPLAN.json')
        try {
	        withCredentials([
            	string(
              		credentialsId: 'bc-api-key',
              		variable: 'BC_API')
            ]) {
                // IF YOU WANT THE BUILD TO PASS, USE THE ITEM WITH --check MEDIUM
		        response = sh(script:"checkov --file MYPLAN.json --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --soft-fail -o junitxml > result.xml || true", returnStdout:true).trim() // -o junitxml > result.xml || true"
                //response = sh(script:"checkov --file MYPLAN.json --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --check MEDIUM --soft-fail -o junitxml > result.xml || true", returnStdout:true).trim()
            }
		
	        response = sh(script:"cat result.xml", returnStdout:true)
	        print "${response}"
            junit skipPublishingChecks: true, testResults: "result.xml"

        withCredentials([
            string(
              	credentialsId: 'bc-api-key',
              	variable: 'BC_API')
            ]) { 
                // IF YOU WANT THE BUILD TO PASS, USE THE ITEM WITH --check MEDIUM   
                sh('checkov --file MYPLAN.json --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --compact --quiet --soft-fail')
                //sh('checkov --file MYPLAN.json --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --check MEDIUM --compact --quiet --soft-fail')
	        }
        }    
	    catch (err) {
            echo err.getMessage()
            echo "Error detected"

            // comment out the below line if you'd like to continue the build or add the --soft-fail to the above checkov cli optiona
            error(err.getMessage())
	    }
    }

    stage('Prisma Cloud Scan Serverless Function') {
        withCredentials([usernamePassword(credentialsId: 'twistlock_creds', passwordVariable: 'TL_PASS', usernameVariable: 'TL_USER')]) {
            sh "./twistcli serverless scan --u $TL_USER --p $TL_PASS --address https://$TL_CONSOLE --details terraform/myHtmlFunction.zip"
        }
    }

    stage('Terraform Apply Lambda Function') {
        sh('terraform -chdir=terraform apply --auto-approve')
    }

    stage('Prisma Cloud scan DockerFile') {
        try {
             //response = sh(script:"checkov --file files/deploy.yml", returnStdout:true).trim() // -o junitxml > result.xml || true"
	        withCredentials([
            	string(
              		credentialsId: 'bc-api-key',
              		variable: 'BC_API')
            ]) {
		        response = sh(script:"checkov --file nginx/Dockerfile --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --soft-fail -o junitxml > result.xml || true", returnStdout:true).trim() // -o junitxml > result.xml || true"
            }
		
	        //print "${response}"
	        response = sh(script:"cat result.xml", returnStdout:true)
	        print "${response}"
            junit skipPublishingChecks: true, testResults: "result.xml"

        withCredentials([
            string(
              	credentialsId: 'bc-api-key',
              	variable: 'BC_API')
            ]) {    
                sh('checkov --file nginx/Dockerfile --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --compact --quiet --soft-fail') 
                // --soft-fail')
	        }
        }    
	    catch (err) {
            echo err.getMessage()
            echo "Error detected"

            // comment out the below line if you'd like to continue the build or add the --soft-fail to the above checkov cli optiona
            error(err.getMessage())
	    }    
    }

    stage('Build custom nginx image') {
        sh('docker build -t custom-nginx -f nginx/Dockerfile .')
    }

    stage('Prisma Cloud Scan container image') {
	    try {
	    // Scan the image
            prismaCloudScanImage ca: '',
            cert: '',
            dockerAddress: 'unix:///var/run/docker.sock',
            // dockerAddress: 'tcp://192.168.10.60:2375',
            image: 'custom-nginx',
	        //image: 'niftyshorts/flask:latest',
            key: '',
            logLevel: 'info',
            podmanPath: '',
            project: '',
            resultsFile: 'prisma-cloud-scan-results.json',
            ignoreImageBuildTime:true
	        prismaCloudPublish resultsFilePattern: 'prisma-cloud-scan-results.json'
        } catch (err) {
	        prismaCloudPublish resultsFilePattern: 'prisma-cloud-scan-results.json'
            echo err.getMessage()
            echo "Error detected"
	        throw RuntimeException("Build failed for some specific reason!")
        }
    }

    stage('Push container image to docker hub') {
        withCredentials([usernamePassword(credentialsId: 'docker_login', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
            sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
        }
        sh('docker tag custom-nginx niftyshorts/custom-nginx')
        sh('docker push niftyshorts/custom-nginx')
    }

    stage('Prisma Cloud scan of k8s manifest IaC') {
        try {
             //response = sh(script:"checkov --file files/deploy.yml", returnStdout:true).trim() // -o junitxml > result.xml || true"
	        withCredentials([
            	string(
              		credentialsId: 'bc-api-key',
              		variable: 'BC_API')
             ]) {
		        response = sh(script:"checkov --file k8s_iac/myNginx.yml --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --check MEDIUM --compact --quiet -o junitxml > result.xml || true", returnStdout:true).trim() // -o junitxml > result.xml || true"
             }
		
	        //print "${response}"
	        response = sh(script:"cat result.xml", returnStdout:true)
	        print "${response}"
            junit skipPublishingChecks: true, testResults: "result.xml"

            withCredentials([
            string(
              	credentialsId: 'bc-api-key',
              	variable: 'BC_API')
            ]) {    
                sh('checkov --file k8s_iac/myNginx.yml --bc-api-key $BC_API --repo-id gbaileymcewan/lambdaapp -b main --check MEDIUM --compact --quiet --soft-fail')
                // --soft-fail')
	        }
	    }
	    catch (err) {
            echo err.getMessage()
            echo "Error detected"
            error(err.getMessage())
	    }
    }

    stage('Deploy to k8s cluster') {
        sh('kubectl delete deployment --ignore-not-found=true mynginx -n myapp')
        sh('kubectl apply -f k8s_iac/myNginx.yml')
        //sh('kubectl delete pods -l app=mynginx -n myapp')
        sh('docker container prune -f')
        sh('docker image prune -f')
    }


    //options {
    //    preserveStashes()
    //    timestamps()
    //    ansiColor('xterm')
    //}
}