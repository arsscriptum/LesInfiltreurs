#include <windows.h>  


typedef long NTSTATUS;

typedef struct _CLIENT_ID
{
	DWORD       uniqueProcess;
	DWORD       uniqueThread;

} CLIENT_ID, *PCLIENT_ID;

typedef struct _THREAD_BASIC_INFORMATION
{
	NTSTATUS    exitStatus;
	PVOID       pTebBaseAddress;
	CLIENT_ID   clientId;
	KAFFINITY               AffinityMask;
	int						Priority;
	int						BasePriority;
	int						v;

} THREAD_BASIC_INFORMATION, *PTHREAD_BASIC_INFORMATION;



typedef enum _SC_SERVICE_TAG_QUERY_TYPE
{
	ServiceNameFromTagInformation = 1,
	ServiceNameReferencingModuleInformation,
	ServiceNameTagMappingInformation,
} SC_SERVICE_TAG_QUERY_TYPE, *PSC_SERVICE_TAG_QUERY_TYPE;

typedef struct _SC_SERVICE_TAG_QUERY
{
	ULONG   processId;
	ULONG   serviceTag;
	ULONG   reserved;
	PVOID   pBuffer;
} SC_SERVICE_TAG_QUERY, *PSC_SERVICE_TAG_QUERY;

typedef ULONG(WINAPI* FN_I_QueryTagInformation)(PVOID, SC_SERVICE_TAG_QUERY_TYPE, PSC_SERVICE_TAG_QUERY);
typedef NTSTATUS(WINAPI* FN_NtQueryInformationThread)(HANDLE, THREAD_INFORMATION_CLASS, PVOID, ULONG, PULONG);

BOOL GetServiceTagString(DWORD processId, ULONG tag, PWSTR pBuffer, SIZE_T bufferSize);
BOOL GetServiceTag(DWORD processId, DWORD threadId, PULONG pServiceTag);
BOOL SetPrivilege();
void KillEventlogThread(DWORD tid);
void SuspendEventlogThread(DWORD tid);
void ResumeEventlogThread(DWORD tid);
BOOL GetServiceTagName(DWORD tid, char* command);
BOOL ListProcessThreads(DWORD pid, char* command);
BOOL EnableDebugPrivilege(BOOL fEnable);
int  getpid();

