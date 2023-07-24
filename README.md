# rt-tb-swag-2023
thunderbird swag for all hands 2023 in montreal

## 2023-07-23 generate text colours and then generate png from text

```bash
cd QUESTION_INFOGRAPHICS
../create-question-answer-vt100graphics.rb ../sorted-by-id-thunderbird-2023-04-01-2023-06-30-questions.csv \
../sorted-by-id-thunderbird-2023-04-01-2023-06-30-answers.csv
xxd -r -p tb-question-colours-1417199-2023-06-30-23-56-27.text >tb-question-colours-1417199-2023-06-30-23-56-27.rgb
magick -depth 8 -size 80x54 tb-question-colours-1417199-2023-06-30-23-56-27.rgb \
tb-question-colours-1417199-2023-06-30-23-56-27.png
```
