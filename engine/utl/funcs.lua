
normalizeVec = function(v1, v2)
	local mag = sqrt(v1 * v1 + v2 * v2)

	if mag > 0 then
    v1, v2 = v1/mag, v2/mag
  end

  return v1, v2
end

linesIntersectFunc = function ( x1, y1, x2, y2, x3, y3, x4, y4 )

  return (
    (relativeCCW(x1, y1, x2, y2, x3, y3) * relativeCCW(x1, y1, x2, y2, x4, y4) <= 0) and
    (relativeCCW(x3, y3, x4, y4, x1, y1) * relativeCCW(x3, y3, x4, y4, x2, y2) <= 0)
  )

end

function relativeCCW ( x1, y1, x2, y2, px, py )

  x2 = x2 - x1;
  y2 = y2 - y1;
  px = px - x1;
  py = py - y1;

  local ccw = px * y2 - py * x2;

  if (ccw == 0.0) then
    --[[
    The point is colinear, classify based on which side of
    the segment the point falls on.  We can calculate a
    relative value using the projection of px,py onto the
    segment - a negative value indicates the point projects
    outside of the segment in the direction of the particular
    endpoint used as the origin for the projection.
    ]]--

    ccw = px * x2 + py * y2;

    if (ccw > 0.0) then
      --[[
      Reverse the projection to be relative to the original x2,y2
      x2 and y2 are simply negated.
      px and py need to have (x2 - x1) or (y2 - y1) subtracted
      from them (based on the original values)
      Since we really want to get a positive answer when the
      point is "beyond (x2,y2)", then we want to calculate
      the inverse anyway - thus we leave x2 & y2 negated.
      ]]--

      px = px - x2;
      py = py - y2;
      ccw = px * x2 + py * y2;

      if (ccw < 0.0) then
        ccw = 0.0;
      end

    end

  end

  if (ccw < 0.0) then

    return -1

	elseif (ccw > 0.0) then

    return 1

  else

    return 0

  end

end