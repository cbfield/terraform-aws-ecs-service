# Templates

Template files used by the module belong here. They can be accessed from the Terraform configurations at the root of the repository like so:

```hcl
templatefile("${path.module}/templates/my-template.json.tpl",{
  my_key_1 = "my-value-1"
  my_key_2 = "my-value-2"
})
```
