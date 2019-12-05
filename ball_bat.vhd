LIBRARY IEEE;   
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT bat_w : INTEGER := 40; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 3; -- bat height in pixels
    -- distance ball moves each frame
    CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
     SIGNAL rec_on : STD_LOGIC; --indicates whether rec at over cuurent pixel position
     SIGNAL rec2_on : STD_LOGIC;
     SIGNAL rec3_on : STD_LOGIC;
     SIGNAL rec4_on : STD_LOGIC;
     SIGNAL rec5_on : STD_LOGIC;
     SIGNAL rec6_on : STD_LOGIC;
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11); --area where the ball spawns
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11); --area where the ball spawns
    -- bat vertical position  
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
     -- rectangle vertical position
 SIGNAL rec_y : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(30,11);  --upper left 
 SIGNAL rec_x : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(60,11);  --upper left oringial (45,11)
  SIGNAL rec_h : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(15,11); 
 SIGNAL rec_w : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(45,11);       
 --Rectangle 2
  SIGNAL rec2_y : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(30,11);  
 SIGNAL rec2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(180,11);  
  SIGNAL rec2_h : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(15,11); 
 SIGNAL rec2_w : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(45,11);  
 --Rectangle 3
  SIGNAL rec3_y : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(30,11);  --upper left 
 SIGNAL rec3_x : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(300,11);  --upper left oringial (45,11)
  SIGNAL rec3_h : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(15,11); 
 SIGNAL rec3_w : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(45,11);       
 --Rectangle 4
  SIGNAL rec4_y : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(30,11);  --upper left 
 SIGNAL rec4_x : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(420,11);  --upper left oringial (45,11)
  SIGNAL rec4_h : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(15,11); 
 SIGNAL rec4_w : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(45,11);       
 --Rectangle 5     
 SIGNAL rec5_y : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(30,11);  --upper left 
 SIGNAL rec5_x : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(540,11);  --upper left oringial (45,11)
  SIGNAL rec5_h : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(15,11); 
 SIGNAL rec5_w : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(45,11); 
 --Rectangle 6
 SIGNAL rec6_y : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(30,11);  --upper left 
 SIGNAL rec6_x : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(660,11);  --upper left oringial (45,11)
  SIGNAL rec6_h : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(15,11); 
 SIGNAL rec6_w : STD_LOGIC_VECTOR(10 DOWNTO 0) :=CONV_STD_LOGIC_VECTOR(45,11);       
--800 X 600     
BEGIN 
    red <= "1111" when rec_on = '1' or rec2_on = '1' or rec3_on = '1' or rec4_on = '1' or rec5_on = '1' or rec6_on = '1' else NOT bat_on & "000"; -- color setup for red ball and cyan bat on white background
    green <= NOT ball_on & "000";
    blue <= NOT ball_on & "000";  
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
      --process for making the rectangle
    recdraw : PROCESS (pixel_row, pixel_col) IS 
  VARIABLE px, py : STD_LOGIC_VECTOR (10 DOWNTO 0);
  BEGIN
  IF((pixel_col >= rec_x - rec_w) OR (rec_x <= rec_w)) AND
    pixel_col <= rec_x + rec_w AND 
    ((pixel_row >= rec_y - rec_h) OR (rec_y <= rec_h)) AND  
    pixel_row <= rec_y + rec_h THEN
    rec_on <= '1'; 
  ELSE 
   rec_on <= '0';
  END IF;
  END PROCESS;

--Making Rectangle 2
    recdraw2 : PROCESS (pixel_row, pixel_col) IS 
  VARIABLE px, py : STD_LOGIC_VECTOR (10 DOWNTO 0);
  BEGIN
  IF((pixel_col >= rec2_x - rec2_w) OR (rec2_x <= rec2_w)) AND
    pixel_col <= rec2_x + rec2_w AND 
    ((pixel_row >= rec2_y - rec2_h) OR (rec2_y <= rec2_h)) AND  
    pixel_row <= rec2_y + rec2_h THEN
    rec2_on <= '1'; 
  ELSE 
   rec2_on <= '0';
  END IF;
  END PROCESS;
--Making Rectangle 3
    recdraw3 : PROCESS (pixel_row, pixel_col) IS 
  VARIABLE px, py : STD_LOGIC_VECTOR (10 DOWNTO 0);
  BEGIN
  IF((pixel_col >= rec3_x - rec3_w) OR (rec3_x <= rec3_w)) AND
    pixel_col <= rec3_x + rec3_w AND 
    ((pixel_row >= rec3_y - rec3_h) OR (rec3_y <= rec3_h)) AND  
    pixel_row <= rec3_y + rec3_h THEN
    rec3_on <= '1'; 
  ELSE 
   rec3_on <= '0';
  END IF;
  END PROCESS;
--Making Rectangle 4
    recdraw4 : PROCESS (pixel_row, pixel_col) IS 
  VARIABLE px, py : STD_LOGIC_VECTOR (10 DOWNTO 0);
  BEGIN
  IF((pixel_col >= rec4_x - rec4_w) OR (rec4_x <= rec4_w)) AND
    pixel_col <= rec4_x + rec4_w AND 
    ((pixel_row >= rec4_y - rec4_h) OR (rec4_y <= rec4_h)) AND  
    pixel_row <= rec4_y + rec4_h THEN
    rec4_on <= '1'; 
  ELSE 
   rec4_on <= '0';
  END IF;
  END PROCESS;
--Making Rectangle 5
    recdraw5 : PROCESS (pixel_row, pixel_col) IS 
  VARIABLE px, py : STD_LOGIC_VECTOR (10 DOWNTO 0);
  BEGIN
  IF((pixel_col >= rec5_x - rec5_w) OR (rec5_x <= rec5_w)) AND
    pixel_col <= rec5_x + rec5_w AND 
    ((pixel_row >= rec5_y - rec5_h) OR (rec5_y <= rec5_h)) AND  
    pixel_row <= rec5_y + rec5_h THEN
    rec5_on <= '1'; 
  ELSE 
   rec5_on <= '0';
  END IF;
  END PROCESS;
--Making Rectangle 6
    recdraw6 : PROCESS (pixel_row, pixel_col) IS 
  VARIABLE px, py : STD_LOGIC_VECTOR (10 DOWNTO 0);
  BEGIN
  IF((pixel_col >= rec6_x - rec6_w) OR (rec6_x <= rec6_w)) AND
    pixel_col <= rec6_x + rec6_w AND 
    ((pixel_row >= rec6_y - rec6_h) OR (rec6_y <= rec6_h)) AND  
    pixel_row <= rec6_y + rec6_h THEN
    rec6_on <= '1'; 
  ELSE 
   rec6_on <= '0';
  END IF;
  END PROCESS;
-- process to move ball once every frame (i.e. once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        ELSIF ball_y <= bsize THEN -- bounce off top wall
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
        ELSIF ball_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            game_on <= '0'; -- and make ball disappear
        END IF;
        -- allow for bounce off left or right of screen
        IF ball_x + bsize >= 800 THEN -- bounce off right wall
            ball_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
        ELSIF ball_x <= bsize THEN -- bounce off left wall
            ball_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
        END IF;
        -- allow for bounce off bat
        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
         (ball_x - bsize/2) <= (bat_x + bat_w) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) THEN
                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        END IF;
                
        --bottom hitbox rec_x
        IF (rec_x) >= (rec_x - rec_w) AND
            (rec_x) <= (rec_x + rec_w) AND 
         (ball_x) <= (rec_x + rec_w) AND
         (ball_x) >= (rec_x - rec_w) AND 
        -- ball_y_motion <= 0 AND
         (ball_y) <= (rec_y + rec_h) AND
         (ball_y) >= (rec_y - rec_h) THEN   
         ball_y_motion <= ball_speed;  
                END IF;

        -- bottom hitbox rec2_x
         IF (rec2_x) >= (rec2_x - rec2_w) AND
            (rec2_x) <= (rec2_x + rec2_w) AND 
         (ball_x) <= (rec2_x + rec2_w) AND
         (ball_x) >= (rec2_x - rec2_w) AND 
        -- ball_y_motion <= 0 AND
         (ball_y) <= (rec2_y + rec2_h) AND
         (ball_y) >= (rec2_y - rec2_h) THEN   
         ball_y_motion <= ball_speed;  
                END IF;  
           
        -- bottom hitbox rec3_x
        IF (rec3_x) >= (rec3_x - rec3_w) AND
            (rec3_x) <= (rec3_x + rec3_w) AND 
         (ball_x) <= (rec3_x + rec3_w) AND
         (ball_x) >= (rec3_x - rec3_w) AND 
        -- ball_y_motion <= 0 AND
         (ball_y) <= (rec3_y + rec3_h) AND
         (ball_y) >= (rec3_y - rec3_h) THEN   
         ball_y_motion <= ball_speed;  
                END IF;
        
        -- bottom hitbox rec4_x
        IF (rec4_x) >= (rec4_x - rec4_w) AND
            (rec4_x) <= (rec4_x + rec4_w) AND 
         (ball_x) <= (rec4_x + rec4_w) AND
         (ball_x) >= (rec4_x - rec4_w) AND 
        -- ball_y_motion <= 0 AND
         (ball_y) <= (rec4_y + rec4_h) AND
         (ball_y) >= (rec4_y - rec4_h) THEN   
         ball_y_motion <= ball_speed;  
                END IF;
        
        -- bottom hitbox rec5_x
         IF (rec5_x) >= (rec5_x - rec5_w) AND
            (rec5_x) <= (rec5_x + rec5_w) AND 
         (ball_x) <= (rec5_x + rec5_w) AND
         (ball_x) >= (rec5_x - rec5_w) AND 
        -- ball_y_motion <= 0 AND
         (ball_y) <= (rec5_y + rec5_h) AND
         (ball_y) >= (rec5_y - rec5_h) THEN   
         ball_y_motion <= ball_speed;  
                END IF;
        
        --bottom hitbox rec6_x
        IF (rec6_x) >= (rec6_x - rec6_w) AND
            (rec6_x) <= (rec6_x + rec6_w) AND 
         (ball_x) <= (rec6_x + rec6_w) AND
         (ball_x) >= (rec6_x - rec6_w) AND 
        -- ball_y_motion <= 0 AND
         (ball_y) <= (rec6_y + rec6_h) AND
         (ball_y) >= (rec6_y - rec6_h) THEN   
         ball_y_motion <= ball_speed;  
                END IF;         
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
        -- compute next ball horizontal position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_x is close to zero and ball_x_motion is negative
        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
        IF temp(11) = '1' THEN
            ball_x <= (OTHERS => '0');
        ELSE ball_x <= temp(10 DOWNTO 0);
        END IF;
    END PROCESS;
END Behavioral;
