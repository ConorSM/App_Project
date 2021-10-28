output "output_webserver_ip_address" {
  value = aws_instance.cyber94_calc2_cmetcalfe_webserver_tf.*.public_ip
}
