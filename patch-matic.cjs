const fs = require('fs')

const file = process.argv[2]
let content = fs.readFileSync(file, 'utf8')

// NOTE: The backslashes need to be escaped twice
const original = '/966'
const patched = '/60'

if (!content.includes(original)) {
  console.error('ERROR: Pattern not found in file!')
  process.exit(1)
}

content = content.replace(original, patched)

fs.writeFileSync(file, content)

console.log('SUCCESS: Patch applied successfully!')
