# Quacks

## returns nil

```
  expect(retval).to be_nil
```

## returns whether this frame is waiting for a roll

```
  expect([true, false]).to include(retval)
```

## takes the number of pins knocked down

```
  expect(pins).to be_a(Integer)
  expect(0..10).to cover(pins)
```

## called only if the frame is waiting for a roll

```
  expect(needs_roll?).to eq(true)
```

## returns whether this frame is waiting for a bonus roll

```
  expect([true, false]).to include(retval)
```

## called only if the frame is waiting for a bonus roll

```
  expect(needs_bonus_roll?).to eq(true)
```

## called only when the frame is complete

```
  expect(needs_roll?).to be_false
  expect(needs_bonus_roll?).to be_false
```

## returns the total score for this frame

```
  expect(retval).to be_a(FixNum)
  expect([0..30]).to cover(retval)
```

## called each time the player rolls a ball

```
  expect(@frames).to be_a(Array)
  expect(0..10).to cover(@frames.length)
```

## a frame that needs a roll should exist here

```
  needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
  expect(needs_roll).to eq(true)
```

## if we are on the 10th frame, the frame may be complete

```
  if @frames.length < 10
    expect(@frames.last.needs_roll?).to eq(true)
  end
```

## only called at the very end of the game

```
  expect(@frames.length).to eq(10)
  needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
  expect(needs_roll).to be_false
```

## returns the total score for the game

```
  expect(retval).to be_a(FixNum)
  expect(0..300).to cover(retval)
```
