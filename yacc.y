%{
	#include<bits/stdc++.h>
	typedef long long ll;
	using namespace std;
    void yyerror(char *msg);
    extern int yylex(void);  	
	
	
	map<ll,string> instList;
	map<ll,vector<string> > basicBlock;
	set<ll> leaders;
	vector<vector<ll> > bbgraph;
	vector<pair<ll,ll> > loop_detected;
	vector<vector<ll> > doms;
	
%}

%%
ss:		
		{
			
		}

%%

ll to_int(string val)
{
	istringstream ss(val);
	ll x;
	ss>>x;
	return x;
}
	
void genFlowGraph()
{
	bbgraph.resize(basicBlock.size());
	for(map<ll,vector<string> >::iterator it=basicBlock.begin();it!=basicBlock.end();it++)
	{
		ll ind=-1;
		string lastStmt=it->second.back();
		if((ind=lastStmt.rfind("goto"))!=-1)
		{
			bbgraph[it->first].push_back(to_int(lastStmt.substr(ind+5)));
			if(ind!=0 && it->first!=basicBlock.size()-1)
			{
				bbgraph[it->first].push_back(it->first+1);
			}
		}
		else
		{
			if(it->first!=basicBlock.size()-1)
				bbgraph[it->first].push_back(it->first+1);
		}
	}
}
void displayFlowGraph()
{
	cout<<"Flow Graph:"<<endl;
	for(ll i=0;i<bbgraph.size();i++)
	{
		cout<<i<<": ";
		for(ll j=0;j<bbgraph[i].size();j++)
		{
			cout<<bbgraph[i][j]<<" ";
		}
		cout<<endl;
	}

	cout<<endl;
}

void findLeaders()
{
	bool flag=true;
	for(map<ll,string>::iterator it=instList.begin();it!=instList.end();it++)
	{
		if(flag)
		{
			leaders.insert(it->first);
			int ind=it->second.rfind("goto");
			if(ind!=-1)
			{
				leaders.insert(to_int(it->second.substr(ind+5)));
				flag=true;
				continue;
			}
			flag=false;
		}

		int ind=it->second.rfind("goto");

		if(ind!=-1)
		{
			leaders.insert(to_int(it->second.substr(ind+5)));
			flag=true;
			continue;
		}
	}
}
void displayLeaders()
{
	cout<<"Leaders:"<<endl;
	for(set<ll>::iterator it=leaders.begin();it!=leaders.end();it++)
	{
		cout<<*it<<endl;
	}
}
void genBasicBlock()
{
	findLeaders();
	map<ll,ll> lineToBlock;
	ll bbno=-1;
	for(map<ll,string>::iterator it = instList.begin();it!=instList.end();it++)
	{
		if(leaders.find(it->first)!=leaders.end())
		{
			bbno++;
		}

		lineToBlock[it->first]=bbno;
	}
	bbno=-1;
	
	for(map<ll,string>::iterator it=instList.begin();it!=instList.end();it++)
	{
		if(leaders.find(it->first)!=leaders.end())
		{
			bbno++;
		}
		int ind=-1;
		string bbinst=it->second;
		if((ind=it->second.rfind("goto"))!=-1)
		{
			bbinst=it->second.substr(0,ind+5) + to_string(lineToBlock[to_int(it->second.substr(ind+5))]);
		}
		basicBlock[bbno].push_back(bbinst);
	}
}
void displayBasicBlocks()
{
	cout<<"Basic Blocks:"<<endl;
	for(map<ll,vector<string> >::iterator it=basicBlock.begin();it!=basicBlock.end();it++)
	{
		cout<<"Block "<<it->first<<":"<<endl;
		for(ll i=0;i<it->second.size();i++)
		{
			cout<<"\t"<<it->second[i]<<endl;
		}
		cout<<endl;
	}
}

void displayInst()
{
	cout<<"Three Address Statements:"<<endl;
	for(map<ll,string>::iterator it=instList.begin();it!=instList.end();it++)
	{
		cout<<it->first<<" "<<it->second<<endl;
	}
	cout<<endl;
}

void DFS_util(int v, bool visited[], int skip)
{
    // Mark the current node as visited and
    // print it
    visited[v] = true;
 
    // Recur for all the vertices adjacent
    // to this vertex
    vector<ll>::iterator i;
    for (i = bbgraph[v].begin(); i != bbgraph[v].end(); ++i)
        if (!visited[*i] && (*i != skip))
            DFS_util(*i, visited, skip);
}


void DFS(int v, bool visited[])
{
    // Mark the current node as visited and
    // print it
    visited[v] = true;
 
    // Recur for all the vertices adjacent
    // to this vertex
    vector<ll>::iterator i;
    for (i = bbgraph[v].begin(); i != bbgraph[v].end(); ++i)
        if (!visited[*i])
            DFS(*i, visited);
}

void dominator_blocks()
{
	int i;
	int V = bbgraph.size();
	bool visited[V];
	for(i=0;i<V;i++)
	{
		visited[i] = false;
		vector<ll> t;
		t.push_back(0);
		doms.push_back(t);
	}
	DFS(0, visited);
	for(i=1;i<V;i++)
	{
		bool temp[V];
		int j;
		for(j=0;j<V;j++)
		{
			temp[j] = false;
		}
		DFS_util(0, temp, i);
		for(j=0;j<V;j++)
		{
			if(visited[j] && !temp[j])
			{
				doms[j].push_back(i);
			}
		}

	}
	cout << "\n";
	cout << "All Dominator blocks for these blocks are: " << "\n";
	cout << "\n";
	for(i=0;i<V;i++)
	{
		int k;
		cout << i << " : ";
		for(k=0;k< doms[i].size();k++)
		{
			cout << doms[i][k] << " ";
		}
		cout << "\n";
	}
	
}




bool isCyclicUtil(ll v, bool visited[], bool *recStack)
{
	int f = 0;
    if(visited[v] == false)
    {
        // Mark the current node as visited and part of recursion stack
        visited[v] = true;
        recStack[v] = true;

        // Recur for all the vertices adjacent to this vertex
        vector<ll>::iterator i;
        for(i = bbgraph[v].begin(); i != bbgraph[v].end(); ++i)
        {
            if (!visited[*i] && isCyclicUtil(*i, visited, recStack) )
            {
				f = 1;
			}
            else if (recStack[*i])
            {
				f = 1;
				loop_detected.push_back({*i,v});
			}
        }
		if(f == 1)
		{
			return true;
		}
  
    }
    recStack[v] = false;  // remove the vertex from recursion stack
    return false;
}
  
void isCyclic()
{
    int V = bbgraph.size();
	//cout << V << "\n";
	// Mark all the vertices as not visited and not part of recursion stack
    bool *visited = new bool[V];
    bool *recStack = new bool[V];
    int i;
    for(i = 0; i < bbgraph.size(); i++)
    {
        visited[i] = false;
        recStack[i] = false;
    }
	int f;
	f = 0;
    // Call the recursive helper function to detect cycle in different
    // DFS trees
    for(int i = 0; i < bbgraph.size(); i++)
	{
    	if(isCyclicUtil(i, visited, recStack))
		{
			f = 1;
		}
	}
	if(f == 1)
	{
		cout << "Loop detected in the code" << "\n";
		cout << "\n";
		cout << "Total no. of loop pairs are: " << loop_detected.size() << "\n";
		cout << '\n';
		int j;
		for(j=0; j<loop_detected.size(); j++)
		{
			cout << "Loop detected between blocks:" << loop_detected[j].first << " ---- " << loop_detected[j].second << "\n";
		}
	}
    else
	{
		cout << "No loop detected at all" << "\n";
	}
}

void initialize_instuction_list()
{
  /* instList[0] = "c = 5";
   instList[1] = "b = 5";
   instList[2] = "t0 = b + d";
   instList[3] =  "a = t0";
   instList[4] =  "t1 = d - a";
   instList[5] =  "b = t1";
   instList[6] =  "b = 8";
   instList[7] =  "t2 = b - a";
   instList[8] = "a = t2";
   instList[9] =  "if a < b goto 10";
   instList[10] = "b = 3";
   instList[11] = "goto 12" ;
   instList[12] = "c = d";
   instList[13] = "b = 9";
   instList[14] = "goto 0";*/

   instList[0] = "f = 1";
   instList[1] = "i = 2";
   instList[2] = "if i > x goto 8";
   instList[3] = "t1 = f * i";
   instList[4] = "f = t1";
   instList[5] = "t2 = i + 1";
   instList[6] = "i = t2";
   instList[7] = "goto 2";
   instList[8] = "b = 5";

   cout<<"INITIALED"<<"\n";

}

void yyerror(char* s)
{
	cout<<s<<endl;
	exit(0);
}


int main()
{

	//yyparse();
	initialize_instuction_list();
	displayInst();

	genBasicBlock();
	displayLeaders();
	displayBasicBlocks();
	genFlowGraph();
	displayFlowGraph();
	isCyclic();
	dominator_blocks();
	
    return 0;
}