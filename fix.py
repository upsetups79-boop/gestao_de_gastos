import os
  for root, dirs, files in os.walk("lib"):
      for f in files:
          if " " in f:                                                                                                                old = os.path.join(root, f)
              new = os.path.join(root, f.replace(" ", "_"))                                                                           os.rename(old, new)
              print(f"Renomeado: {f}")
  print("Pronto!")