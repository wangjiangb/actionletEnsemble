#include <stdlib.h>
#include <stdio.h>
#include "DepthMapBinFileIO.h"

int ReadDepthMapBinFileHeader(FILE * fp, int &retNumFrames, int &retNCols, int &retNRows)
{
	if(fp == NULL)
		return 0;


	fread(&retNumFrames, 4, 1, fp); //read 4 bytes 
	fread(&retNCols, 4, 1, fp);
	fread(&retNRows, 4, 1, fp);
	//fscanf(fp, "%i", &retNumFrames);
	//fscanf(fp, "%i", &retWidth);
	//fscanf(fp, "%i", &retHeight);

	return 1;
}

//the caller needs to allocate space for <retDepthMap>
int ReadDepthMapBinFileNextFrame(FILE * fp, int numCols, int numRows, CDepthMap & retDepthMap)
{
	int r,c;
	//for(h=0; h<height; h++) //for each row
	int * tempRow = new int[numCols];
	uint8_t* tempRowID = new uint8_t[numCols];
	for(r=0;r<numRows;r++) //one row at a time
	{
		fread(tempRow, 4, numCols, fp);
		fread(tempRowID, 1,numCols,fp);
		for(c=0; c<numCols; c++) //for each colume	
		{
			//int temp=0;
			//fread(&temp, 4, 1, fp);
			//retDepthMap.SetItem(r,c,temp);
			int temp = tempRow[c];
			retDepthMap.SetItem(r,c,(float) temp);
			retDepthMap.SetSkeletonID(r,c,tempRowID[c]);
		}
	}
	delete[] tempRow;
	tempRow = NULL;
	delete[] tempRowID;
	tempRowID = NULL;
	return 1;	
}

//<fp> must be opened with "wb"
int WriteDepthMapBinFileHeader(FILE * fp, int nFrames, int nCols, int nRows)
{
	if(fp == NULL)
		return 0;


	fwrite(&nFrames, 4, 1, fp); //read 4 bytes 
	fwrite(&nCols, 4, 1, fp);
	fwrite(&nRows, 4, 1, fp);
	//fscanf(fp, "%i", &retNumFrames);
	//fscanf(fp, "%i", &retWidth);
	//fscanf(fp, "%i", &retHeight);

	return 1;
}

//<fp> must be opened with "wb"
int WriteDepthMapBinFileNextFrame(FILE * fp, const CDepthMap & depthMap)
{
	int numCols = depthMap.GetNCols();
	int numRows = depthMap.GetNRows();
	
	int r,c;
	//for(h=0; h<height; h++) //for each row
	int * tempRow = new int[numCols];
	uint8_t* tempRowID = new uint8_t[numCols];
	for(r=0;r<numRows;r++) //one row at a time
	{
		for(c=0; c<numCols; c++) //for each colume
		{
			int temp = (int) (depthMap.GetItem(r,c));
			tempRow[c] = temp;
			tempRowID[c] = depthMap.GetSkeletonID(r,c);
		}
		fwrite(tempRow, 4, numCols, fp);
		fwrite(tempRowID,1,numCols,fp);
	}
	delete[] tempRow;
	tempRow = NULL;
	delete[] tempRowID;
	tempRowID = NULL;
	return 1;	
}