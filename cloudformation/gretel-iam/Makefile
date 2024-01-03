build:
	cdk synth -j -o output_template -q

process:
	cat output_template/GretelIamStack.template.json | jq 'del( .Resources.CDKMetadata ) | del( .Resources[].Metadata ) | del( .Rules.CheckBootstrapVersion ) | del( .Parameters.BootstrapVersion ) | del ( .Conditions.CDKMetadataAvailable )' > output_template/cloudformation.json

clean:
	rm -f output_template/GretelIamStack.assets.json
	rm -f output_template/GretelIamStack.template.json
	rm -f output_template/manifest.json
	rm -f output_template/tree.json

release: build process clean