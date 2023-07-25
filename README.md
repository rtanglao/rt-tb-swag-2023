# rt-tb-swag-2023
thunderbird swag for all hands 2023 in montreal

### 2023-07-25 let's generate some infographics :-)
```bash
magick montage '*80x*.png' -tile 80x28 -adjoin +frame +label +shadow -geometry '80x+0+0<' \
no-spaces-80by28-tb-support-questions-infographic-april-june2023.png
magick montage '*.png' -tile 28x tb-support-questions-infographic-april-june2023.png
```
## 2023-07-24 generate RGBA directly and then PNG using rush

```bash
../rgba-create-question-answer-vt100graphics.rb ../sorted-by-id-thunderbird-2023-04-01-2023-06-30-questions.csv \
../sorted-by-id-thunderbird-2023-04-01-2023-06-30-answers.csv
# regex is capture what's after "80x" and before ".rgba" at the end of the string ("$")
ls -1 *.rgba | rush 'magick -depth 8 -size 80x{@([0-9]+).rgba$}' {} {.}.png
```

## 2023-07-23 generate text colours and then generate png from text

```bash
cd QUESTION_INFOGRAPHICS
../create-question-answer-vt100graphics.rb ../sorted-by-id-thunderbird-2023-04-01-2023-06-30-questions.csv \
../sorted-by-id-thunderbird-2023-04-01-2023-06-30-answers.csv
xxd -r -p tb-question-colours-1417199-2023-06-30-23-56-27.text >tb-question-colours-1417199-2023-06-30-23-56-27.rgb
magick -depth 8 -size 80x54 tb-question-colours-1417199-2023-06-30-23-56-27.rgb \
tb-question-colours-1417199-2023-06-30-23-56-27.png
```
