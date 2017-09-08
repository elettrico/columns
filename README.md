# columns
Minetest mod for creating columns "collections" with worldedit

## what?
I like building big structures, with big spaces, so I write this basic and incomplete mod: it uses cylinder from worldedit 
and create columns with a larger (or smaller) top, something like gothic ones.

## how do I use it?
First of all: expect errors.

Build colums using chat commands (axis conventions are the same as worldedit):

```//column x/y/z/? <length> <radius> <length_end> <radius_end> <node>```

Add a column at WorldEdit position 1 along the x/y/z/? axis with length <length> of radius <radius> and then shifting to 
<radius_end> at the end for <length_end>, composed of <node>. The shift from <radius> to <radius_end> is done calculating a
parabolic curve, so if you set a length_end equals to the difference between radius and radius_end you will not obtain 
a diagonal "line".

```//multicolumn x/y/z/? <length> <radius> <length_end> <radius_end> <repeat-1> <repeat-2> <offset> <node>```

Same as before, but the column is repeated <repeat-1> and <repeat-2> times over others axes (z and y if the axis is x, 
x and z if the axis is y, x and y if the axis is z) using a distance between colums of <offset> nodes.

## that's all?
Yes. And expect errors.

## I've found an error!
Actually I don't have much time to work on this, you can submit an issue and I'll see what I can do, or fork and debug.

## screenshots?
Sure! Two there, more in the "screenshots" directory.

**A cathedral like silver sand set of columns**
![A cathedral like silver sand set of columns](https://github.com/elettrico/columns/blob/master/screenshots/cathedral_like_silversand.png)

**Bronze platforms? Maybe made by ancient aliens?**
![Bronze platforms? Maybe made by ancient aliens?](https://github.com/elettrico/columns/blob/master/screenshots/bronze_colums_or_platform.png)
