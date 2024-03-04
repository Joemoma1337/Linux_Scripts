def calculate_accepted_color_range(expected_color, tolerance):
    lower_bound = tuple(c - tolerance for c in expected_color)
    upper_bound = tuple(c + tolerance for c in expected_color)
    return lower_bound, upper_bound

expected_color1 = (235, 236, 239)
tolerance = 10

lower_bound, upper_bound = calculate_accepted_color_range(expected_color1, tolerance)

print(f"Expected Color: {expected_color1}")
print(f"Tolerance: {tolerance}")
print(f"Accepted Color Range: {lower_bound} to {upper_bound}")

# Print out the accepted colors within the range
accepted_colors = [(r, g, b) for r in range(lower_bound[0], upper_bound[0] + 1)
                                  for g in range(lower_bound[1], upper_bound[1] + 1)
                                  for b in range(lower_bound[2], upper_bound[2] + 1)]

print("Accepted Colors:")
for color in accepted_colors:
    print(color)
