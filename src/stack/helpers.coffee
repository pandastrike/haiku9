# CloudFormation stack names must be [A-Za-z0-9-] and less than 128 characters
generateStackName = (name) -> name.replace(/\./g, "-")[...128]

export {generateStackName}
