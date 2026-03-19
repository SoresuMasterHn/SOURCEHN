aYUDAME A REVISAR ESTE CODIGO Y MEJORAR **Free
  dcl-s num1 packed(10:2);
  dcl-s num2 packed(10:2);
  dcl-s operator char(1);
  dcl-s result packed(10:2);

// Display menu
  write 'Calculator Menu:';
  write '1. Addition';
  write '2. Subtraction';
  write '3. Multiplication';
  write '4. Division';
  write 'Enter your choice (1-4):';
  read operator;

// Read input values
  write 'Enter the first number:';
  read num1;
  write 'Enter the second number:';
  read num2;

// Perform calculation
  select;
      when operator = '1';
          result = num1 + num2;
      when operator = '2';
          result = num1 - num2;
      when operator = '3';
          result = num1 * num2;
      when operator = '4';
          result = num1 / num2;
      other;
          write 'Invalid operator!';
  endsl;

// Display result
  write 'Result: ' + %char(result);
           *inlr = *on;
