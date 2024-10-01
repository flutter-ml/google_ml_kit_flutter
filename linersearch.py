// Java code to find largest three elements
// in an array

class PrintLargest {
    /* Function to print three largest elements */
    static void print3largest(int arr[], int arr_size)
    {
        int i, first, second, third;

        /* There should be atleast three elements */
        if (arr_size < 3) {
            System.out.print(" Invalid Input ");
            return;
        }

        third = first = second = Integer.MIN_VALUE;
        for (i = 0; i < arr_size; i++) {
            /* If current element is greater than
            first*/
            if (arr[i] > first) {
                third = second;
                second = first;
                first = arr[i];
            }

            /* If arr[i] is in between first and
            second then update second  */
            else if (arr[i] > second) {
                third = second;
                second = arr[i];
            }

            else if (arr[i] > third)
                third = arr[i];
        }

        System.out.println("Three largest elements are " + first + " " + second + " " + third);
    }

    /* Driver program to test above function*/
    public static void main(String[] args)
    {
        int arr[] = { 12, 13, 1, 10, 34, 1 };
        int n = arr.length;
        print3largest(arr, n);
    }
}
/*This code is contributed by Prakriti Gupta 
and edited by Ayush Singla(@ayusin51)*/
