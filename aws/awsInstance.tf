
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "myvm" {
       ami = "ami-03f4878755434977f"
       instance_type = "t2.micro"
       user_data = file("userdata.txt")
       associate_public_ip_address = true
       root_block_device {
         volume_type = "gp2"
         volume_size = "30"
         delete_on_termination = false
       }
            tags = {
            Name = "MyVm"
}

}
output "IPAddress" {
     value = "${aws_instance.myvm.public_ip}"
}
