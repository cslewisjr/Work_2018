/*AWS Provider Configuration
*/

provider "aws" {
    access_key = "AKIAJ5LWJFSKW4K5A4XQ"
    secret_key = "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"
    region = "us-east-2"
    }

    resource "aws_instance" "Dev_Build_TEST01"{

        ami ="ami-0e28ec6753aeec976"
        instance_type = "t2.micro"

        tags {
            Name = "DEV_BUILD_TEST01"
            Use = "TestServer01"
        }
    

    }
        resource "aws_instance" "Dev_Build_TEST02"{

        ami ="ami-0e28ec6753aeec976"
        instance_type = "t2.micro"
           
            tags {
            Name = "DEV_BUILD_TEST02"
            Use = "TestServer01"
        }
    }
    
