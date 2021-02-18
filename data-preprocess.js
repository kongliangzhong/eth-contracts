const fs = require("fs");


function parse2020LrcRewards() {
  const lines = fs.readFileSync("2020_reward_2.tsv", "utf-8").split("\n");
  const allItems = [];
  const revocableItems = [];
  const unrevocableItems = [];

  let sum1 = 0;
  let sum2 = 0;
  let sum3 = 0;
  for (const line of lines) {
    const fields = line.split("\t").filter(i => i);
    if (fields[0].startsWith("0x")) {
      // console.log("line:", line);
      const member = fields[0];
      const rewardAmount = Number(fields[1].replace(/[,"]/g, ""));
      sum1 += rewardAmount;

      const unrevocableAmount = Number(fields[2].replace(/[,"]/g, ""));
      const revocableAmount = Number(fields[3].replace(/[,"]/g, ""));
      sum2 += unrevocableAmount;
      sum3 += revocableAmount;

      if (unrevocableAmount > 0) {
        unrevocableItems.push([member, unrevocableAmount]);
      }

      if (revocableAmount > 0) {
        revocableItems.push([member, revocableAmount]);
      }
    } else {
      console.log("invalid line:", line);
    }
  }

  console.log(sum1, sum2, sum3);

  // let sum = revocableItems.map(i => i[1]).reduce((a, b) => a + b, 0);
  // console.log("sum:", sum);
  // sum = unrevocableItems.map(i => i[1]).reduce((a, b) => a + b, sum);
  // console.log("sum:", sum);

  // console.log("revocableItems:", revocableItems);

  // let sum4 = 0;
  // for (const item of revocableItems) {
  //   sum4 += item[1];
  // }
  // console.log("sum4:", sum4);

  // console.log("unrevocableItems:", unrevocableItems);
  console.log("unrevocableItems length:", unrevocableItems.length);
  console.log("unrevocableItems members:", unrevocableItems.map(i => i[0]));
  const unrevocableAmounts = unrevocableItems.map(i => i[1]);
  console.log("unrevocableItems amounts:");
  for (const am of unrevocableAmounts) {
    console.log(am + ",");
  }

  console.log("revocableItems length:", revocableItems.length);
  console.log("revocableItems members:", revocableItems.map(i => i[0]));
  const revocableAmounts = revocableItems.map(i => i[1]);
  console.log("revocableItems amounts:");
  for (const am of revocableAmounts) {
    console.log(am + ",");
  }

}

function main() {
  parse2020LrcRewards();
}

main();
