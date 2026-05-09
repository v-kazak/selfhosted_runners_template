output "summary" {
  description = "Красивый текстовый вывод для терминала"
  value       = <<-EOT
====================================================
 Terraform Apply Summary
----------------------------------------------------
 VM count     : ${length(yandex_compute_instance.instance)}
 SSH user     : ${var.ssh_user}
 Zone         : ${var.zone}

 Addresses:
${length(yandex_compute_instance.instance) > 0 ? join("\n", formatlist("   - %s", [for instance in yandex_compute_instance.instance : coalesce(instance.network_interface[0].nat_ip_address, instance.network_interface[0].ip_address)])) : "   - <no instances>"}

 Quick SSH:
   ssh ${var.ssh_user}@${try(coalesce(yandex_compute_instance.instance[0].network_interface[0].nat_ip_address, yandex_compute_instance.instance[0].network_interface[0].ip_address), "<no instances>")}
====================================================
  EOT
}